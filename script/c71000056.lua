--大墓之死地
-- 卡片类型：魔法卡, 场地
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- 这个卡名的①②效果1回合只能使用1次。
	-- ①：作为这张卡的发动时的效果处理。从卡组把1只「大墓」怪兽加入手卡或送去墓地。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_TOGRAVE + CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, m)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：把自己场上1只对方怪兽送去墓地才能发动，这个回合，对方墓地·除外状态的怪兽也当做「大墓」怪兽使用。这个效果发动的回合，自己只能从额外卡组特殊召唤「大墓」怪兽。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1, m + 1)
	e2:SetCost(cm.cost2)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

function cm.filter(c)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_MONSTER)
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(cm.filter, tp, LOCATION_DECK, 0, 1, nil) end
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
	local opt = Duel.SelectOption(tp, aux.Stringid(m, 3), aux.Stringid(m, 2))
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_OPERATECARD)
	local g = Duel.SelectMatchingCard(tp, cm.filter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g > 0 then
		if opt == 0 then
			Duel.SendtoGrave(g, REASON_EFFECT)
		else
			Duel.SendtoHand(g, nil, REASON_EFFECT)
			Duel.ConfirmCards(1 - tp, g)
		end
	end
end

function cm.cost2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(cm.costfilter, tp, LOCATION_MZONE, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g = Duel.SelectMatchingCard(tp, cm.costfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
	Duel.SendtoGrave(g, REASON_COST)
end

function cm.costfilter(c)
	return c:GetOwner() ~= c:GetControler()
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return true end
end

function cm.filter0(c, e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end

function cm.fusmatfilter(c)
	return c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end

function cm.fdfilter2(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() or c:IsLocation(LOCATION_REMOVED)
end

function cm.filter2(c, e, tp, mg, f, chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c)) and c:IsSetCard(0x3e11)
		and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, false, false) and
		c:CheckFusionMaterial(mg, nil, chkf, true)
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	-- 这个回合，对方墓地·除外状态的怪兽也当做「大墓」怪兽使用
	local e1 = Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetTargetRange(0, LOCATION_GRAVE + LOCATION_REMOVED)
	e1:SetTarget(cm.tgfilter)
	e1:SetValue(0x3e11)
	e1:SetReset(RESET_PHASE + PHASE_END)
	Duel.RegisterEffect(e1, tp)

	Duel.BreakEffect()

	local chkf = tp
	local mg1 = Duel.GetMatchingGroup(cm.fusmatfilter, tp, 0, LOCATION_GRAVE, nil)
	local sg1 = Duel.GetMatchingGroup(cm.filter2, tp, LOCATION_EXTRA, 0, nil, e, tp, mg1, nil, chkf)
	local res = Duel.IsExistingMatchingCard(cm.filter2, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, mg1, nil, chkf)
	if not res then
		local ce = Duel.GetChainMaterial(tp)
		if ce ~= nil then
			local fgroup = ce:GetTarget()
			local mg2 = fgroup(ce, e, tp)
			local mf = ce:GetValue()
			res = Duel.IsExistingMatchingCard(cm.filter2, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, mg2, mf,
				chkf)
		end
	end
	if res then
		local mg2 = nil
		local sg2 = nil
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
				local num = Duel.SendtoDeck(mat1, nil, SEQ_DECKTOP, REASON_EFFECT + REASON_MATERIAL + REASON_FUSION)
				Duel.BreakEffect()
				if num == mat1:GetCount() then
					Duel.SpecialSummon(tc, SUMMON_TYPE_FUSION, tp, tp, false, false, POS_FACEUP)
				end
			else
				local mat2 = Duel.SelectFusionMaterial(tp, tc, mg2, nil, chkf)
				local fop = ce:GetOperation()
				fop(ce, e, tp, tc, mat2)
			end
			tc:CompleteProcedure()
		end
	end

	-- 这个效果发动的回合，自己只能从额外卡组特殊召唤「大墓」怪兽
	local e2 = Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1, 0)
	e2:SetReset(RESET_PHASE + PHASE_END)
	e2:SetTarget(cm.splimit)
	Duel.RegisterEffect(e2, tp)
end

function cm.tgfilter(e, c)
	return c:IsType(TYPE_MONSTER)
end

function cm.splimit(e, c, sump, sumtype, sumpos, targetp, se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x3e11)
end
