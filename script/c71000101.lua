--大墓之葬送者
-- 卡片类型：怪兽卡, 效果
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- 这个卡名的①②效果1回合各能使用1次。
	-- ①：自己场上有「大墓」卡存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从双方卡组上面把2张卡送去墓地。这个回合，自己不是不死族怪兽不能从卡组特殊召唤。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1, m + 1)
	e1:SetCondition(cm.e1con)
	e1:SetTarget(cm.e1tg)
	e1:SetOperation(cm.e1op)
	c:RegisterEffect(e1)

	-- ②：把墓地的这张卡除外才能发动。从自己墓地把不死族融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。自己场上有对方怪兽的场合，这个效果在对方回合也能发动。
	-- 二速效果版：自己场上存在原本持有者为对方的怪兽时才能发动
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_REMOVE + CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1, m + 2)
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(cm.e2con_quick)
	e2:SetTarget(cm.e2tg)
	e2:SetOperation(cm.e2op)
	c:RegisterEffect(e2)

	-- 起动效果版：自己场上不存在原本持有者为对方的怪兽时才能发动
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m, 1))
	e3:SetCategory(CATEGORY_REMOVE + CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1, m + 2)
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(cm.e2con_ignition)
	e3:SetTarget(cm.e2tg)
	e3:SetOperation(cm.e2op)
	c:RegisterEffect(e3)
end

function cm.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3E11)
end

function cm.e1con(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsExistingMatchingCard(cm.cfilter, tp, LOCATION_ONFIELD, 0, 1, nil)
end

function cm.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
			and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function cm.e1op(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
		-- 那之后，可以从双方卡组上面把2张卡送去墓地
		if Duel.SelectYesNo(tp, aux.Stringid(m, 2)) then
			local g1 = Duel.GetDecktopGroup(tp, 2)
			local g2 = Duel.GetDecktopGroup(1 - tp, 2)
			local g = g1:Clone()
			g:Merge(g2)
			if #g > 0 then
				Duel.SendtoGrave(g, REASON_EFFECT)
			end
		end

		-- 这个回合，自己不是不死族怪兽不能从卡组特殊召唤
		local e1 = Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1, 0)
		e1:SetTarget(cm.splimit)
		e1:SetReset(RESET_PHASE + PHASE_END)
		Duel.RegisterEffect(e1, tp)
	end
end

function cm.splimit(e, c)
	return not c:IsRace(RACE_ZOMBIE) and c:IsLocation(LOCATION_DECK)
end

function cm.spcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
		and Duel.IsExistingMatchingCard(cm.cfilter, tp, LOCATION_ONFIELD, 0, 1, nil)
end

function cm.e2con_quick(e, tp, eg, ep, ev, re, r, rp)
	-- 自己场上存在原本持有者为对方的怪兽
	return Duel.IsExistingMatchingCard(cm.oppmonfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function cm.e2con_ignition(e, tp, eg, ep, ev, re, r, rp)
	-- 自己场上不存在原本持有者为对方的怪兽
	return not Duel.IsExistingMatchingCard(cm.oppmonfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function cm.oppmonfilter(c)
	return c:GetOwner() ~= c:GetControler()
end

function cm.fusfilter(c, e, tp, mg, f, chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_ZOMBIE) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, false, false) and
		c:CheckFusionMaterial(mg, nil, chkf, true)
end

function cm.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		local chkf = tp
		local mg1 = Duel.GetMatchingGroup(function(c) return c:IsAbleToRemove() end, tp, LOCATION_GRAVE,
			0, 1, nil)
		mg1:RemoveCard(e:GetHandler())
		local res = Duel.IsExistingMatchingCard(cm.fusfilter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, mg1, nil, chkf)
		if not res then
			local ce = Duel.GetChainMaterial(tp)
			if ce ~= nil then
				local fgroup = ce:GetTarget()
				local mg2 = fgroup(ce, tp, eg)
				local mf = ce:GetValue()
				res = Duel.IsExistingMatchingCard(cm.fusfilter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, mg2, mf, chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0, CATEGORY_FUSION_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function cm.e2op(e, tp, eg, ep, ev, re, r, rp)
	local chkf = tp
	local mg1 = Duel.GetMatchingGroup(function(c) return c:IsAbleToRemove() end, tp, LOCATION_GRAVE,
		0, 1, nil)
	mg1:RemoveCard(e:GetHandler())
	local sg1 = Duel.GetMatchingGroup(cm.fusfilter, tp, LOCATION_EXTRA, 0, nil, e, tp, mg1, nil, chkf)
	local mg2 = nil
	local sg2 = nil
	local ce = Duel.GetChainMaterial(tp)
	if ce ~= nil then
		local fgroup = ce:GetTarget()
		mg2 = fgroup(ce, tp, eg)
		local mf = ce:GetValue()
		sg2 = Duel.GetMatchingGroup(cm.fusfilter, tp, LOCATION_EXTRA, 0, nil, e, tp, mg2, mf, chkf)
	end
	if #sg1 > 0 or (sg2 and #sg2 > 0) then
		local sg = sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local tg = sg:Select(tp, 1, 1, nil)
		local tc = tg:GetFirst()
		if sg1:IsContains(tc) and (sg2 == nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp, ce:GetDescription())) then
			local mat = Duel.SelectFusionMaterial(tp, tc, mg1, nil, chkf)
			tc:SetMaterial(mat)
			Duel.Remove(mat, POS_FACEUP, REASON_EFFECT + REASON_MATERIAL + REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc, SUMMON_TYPE_FUSION, tp, tp, false, false, POS_FACEUP)
		else
			local mat2 = Duel.SelectFusionMaterial(tp, tc, mg2, nil, chkf)
			local fop = ce:GetOperation()
			fop(ce, tp, eg, ep, ev, re, r, rp, tc, mat2)
		end
		tc:CompleteProcedure()
	end
end
