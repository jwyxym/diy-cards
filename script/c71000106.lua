--大墓之司祭主
-- 卡片类型：怪兽卡, 效果, 连接
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- 「大墓」怪兽2只以上
	-- 这个卡名的①②效果1回合各能使用1次。
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c, cm.matfilter, 2, 3)

	-- ①：这张卡连接召唤成功的场合才能发动。从自己墓地把1只「大墓」怪兽特殊召唤。那之后，自己场上有对方怪兽的场合，可以再从卡组把1只「大墓」卡送去墓地或除外。这个回合，自己不是不死族怪兽不能从额外卡组特殊召唤。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1, m + 1)
	e1:SetCondition(cm.e1con)
	e1:SetTarget(cm.e1tg)
	e1:SetOperation(cm.e1op)
	c:RegisterEffect(e1)

	-- ②：这张卡被除外的场合，以对方墓地1只怪兽为对象才能发动，那只怪兽效果无效并特殊召唤到自己场上，攻击力·守备力变为0，不能作为融合·同调·超量·链接的素材。
	-- local e2 = Effect.CreateEffect(c)
	-- e2:SetDescription(aux.Stringid(m, 1))
	-- e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	-- e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	-- e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
	-- e2:SetCode(EVENT_REMOVE)
	-- e2:SetCountLimit(1, m + 2)
	-- e2:SetTarget(cm.e2tg)
	-- e2:SetOperation(cm.e2op)
	-- c:RegisterEffect(e2)

	-- ②：这张卡被除外的场合才能发动。从卡组把不死族融合怪兽卡决定的融合素材怪兽最多3只送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个效果发动后，自己不是「大墓」怪兽不能从额外卡组特殊召唤。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1, m + 2)
	e2:SetTarget(cm.e2tg2)
	e2:SetOperation(cm.e2op2)
	c:RegisterEffect(e2)
end

function cm.matfilter(c)
	return c:IsSetCard(0x3E11) and c:IsRace(RACE_ZOMBIE)
end

function cm.e1con(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function cm.spfilter(c, e, tp)
	return c:IsSetCard(0x3E11) and c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function cm.tgfilter(c)
	return c:IsSetCard(0x3E11) and (c:IsAbleToGrave() or c:IsAbleToRemove())
end

function cm.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
			and Duel.IsExistingMatchingCard(cm.spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
end

function cm.oppmonfilter(c)
	return c:GetOwner() ~= c:GetControler()
end

function cm.e1op(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, cm.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
	if #g > 0 and Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) > 0 then
		-- 那之后，自己场上有对方怪兽的场合，可以再从卡组把1只「大墓」卡送去墓地或除外
		local g2 = Duel.GetMatchingGroup(cm.oppmonfilter, tp, LOCATION_MZONE, 0, nil)
		if #g2 > 0 and Duel.IsExistingMatchingCard(cm.tgfilter, tp, LOCATION_DECK, 0, 1, nil) then
			if Duel.SelectYesNo(tp, aux.Stringid(m, 2)) then
				Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
				local sg = Duel.SelectMatchingCard(tp, cm.tgfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
				if #sg > 0 then
					if sg:GetFirst():IsAbleToRemove() and Duel.SelectYesNo(tp, aux.Stringid(m, 3)) then
						Duel.Remove(sg, POS_FACEUP, REASON_EFFECT)
					else
						Duel.SendtoGrave(sg, REASON_EFFECT)
					end
				end
			end
		end

		-- 这个回合，自己不是不死族怪兽不能从额外卡组特殊召唤
		local e1 = Effect.CreateEffect(e:GetHandler())
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
	return not c:IsRace(RACE_ZOMBIE) and c:IsLocation(LOCATION_EXTRA)
end

function cm.xyzfilter(c, e, tp)
	return c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function cm.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1 - tp) and cm.xyzfilter(chkc, e, tp) end
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
			and Duel.IsExistingTarget(cm.xyzfilter, tp, 0, LOCATION_GRAVE, 1, nil, e, tp)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectTarget(tp, cm.xyzfilter, tp, 0, LOCATION_GRAVE, 1, 1, nil, e, tp)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function cm.filter1(c, e)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end

function cm.filter2(c, e, tp, m, f, chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_ZOMBIE) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, false, false) and c:CheckFusionMaterial(m, nil, chkf)
end

function cm.fcheck(tp, sg, fc)
	return sg:FilterCount(cm.ffilter, nil, tp) <= 3
end

function cm.gcheck(sg)
	return #sg <= 3
end

function cm.ffilter(c, tp)
	return c:IsControler(tp)
end

function cm.e2tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	local chkf = tp
	local mg1 = Duel.GetMatchingGroup(cm.filter1, tp, LOCATION_DECK, 0, nil, e)
	if chk == 0 then
		aux.FCheckAdditional = cm.fcheck
		aux.GCheckAdditional = cm.gcheck
		local res = Duel.IsExistingMatchingCard(cm.filter2, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, mg1, nil, chkf)
		if not res then
			local ce = Duel.GetChainMaterial(tp)
			if ce ~= nil then
				local fgroup = ce:GetTarget()
				local mg2 = fgroup(ce, e, tp)
				local mf = ce:GetValue()
				res = Duel.IsExistingMatchingCard(cm.filter2, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, mg2, mf, chkf)
			end
		end
		aux.FCheckAdditional = nil
		aux.GCheckAdditional = nil
		return res
	end
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, mg1, 1, tp, LOCATION_DECK)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, 0)
end

function cm.e2op2(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	aux.FCheckAdditional = cm.fcheck
	aux.GCheckAdditional = cm.gcheck
	local chkf = tp
	local mg1 = Duel.GetMatchingGroup(cm.filter1, tp, LOCATION_DECK, 0, nil, e)
	local sg1 = Duel.GetMatchingGroup(cm.filter2, tp, LOCATION_EXTRA, 0, nil, e, tp, mg1, nil, chkf)
	local mg2 = nil
	local sg2 = nil
	local ce = Duel.GetChainMaterial(tp)
	if ce ~= nil then
		local fgroup = ce:GetTarget()
		mg2 = fgroup(ce, e, tp)
		local mf = ce:GetValue()
		sg2 = Duel.GetMatchingGroup(cm.filter2, tp, LOCATION_EXTRA, 0, nil, e, tp, mg2, mf, chkf)
	end
	if sg1:GetCount() > 0 or (sg2 ~= nil and sg2:GetCount() > 0) then
		local sg = sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local tg = sg:Select(tp, 1, 1, nil)
		local tc = tg:GetFirst()
		if sg1:IsContains(tc) and (sg2 == nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp, ce:GetDescription())) then
			local mat1 = Duel.SelectFusionMaterial(tp, tc, mg1, nil, chkf)
			tc:SetMaterial(mat1)
			Duel.SendtoGrave(mat1, REASON_EFFECT + REASON_MATERIAL + REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc, SUMMON_TYPE_FUSION, tp, tp, false, false, POS_FACEUP)
		else
			local mat2 = Duel.SelectFusionMaterial(tp, tc, mg2, nil, chkf)
			local fop = ce:GetOperation()
			fop(ce, e, tp, tc, mat2)
		end
	end
	aux.FCheckAdditional = nil
	aux.GCheckAdditional = nil
	local e2 = Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1, 0)
	e2:SetReset(RESET_PHASE + PHASE_END)
	e2:SetTarget(cm.splimit2)
	Duel.RegisterEffect(e2, tp)
end

function cm.splimit2(e, c, sump, sumtype, sumpos, targetp, se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x3e11)
end
