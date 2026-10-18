--大墓之殉葬
-- 卡片类型：魔法卡, 速攻
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：从自己的手卡·场上把「大墓」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。自己场上有对方怪兽存在的场合，也能从自己或对方的除外状态把融合素材怪兽返回卡组作为代替（这个场合，特殊召唤当作融合召唤）。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_TOGRAVE + CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, m + 1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡被「大墓」卡的效果送去墓地或除外状态的场合才能发动。从自己或对方卡组上面把2张卡送去墓地，那之后，这张卡加入手卡。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_DECKDES + CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1, m + 2)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(cm.condition3)
	e2:SetTarget(cm.tg3)
	e2:SetOperation(cm.op3)
	c:RegisterEffect(e2)
	local e3 = e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end

function cm.filter(c, fc, sumtype, tp)
	return c:IsSetCard(0x3e11) and c:IsCanBeFusionMaterial(fc, sumtype)
end

function cm.fusionfilter(c, e, tp, mg, mf, chkf)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_FUSION) and
		(mf == nil or mf(c, mg, tp)) and
		c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, false, false) and
		c:CheckFusionMaterial(mg, nil, chkf)
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		local chkf = tp
		local mg1 = Duel.GetFusionMaterial(tp)
		local res = Duel.IsExistingMatchingCard(cm.fusionfilter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, mg1, nil, chkf)
		if not res then
			local ce = Duel.GetChainMaterial(tp)
			if ce ~= nil then
				local fgroup = ce:GetTarget()
				local mg2 = fgroup(ce, e, tp)
				local mf = ce:GetValue()
				res = Duel.IsExistingMatchingCard(cm.fusionfilter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, mg2, mf, chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local chkf = tp
	local mg1 = Duel.GetMatchingGroup(cm.filter, tp, LOCATION_HAND + LOCATION_MZONE, 0, nil, nil, SUMMON_TYPE_FUSION, tp)
	-- 自己场上有对方怪兽存在的场合，也能从自己或对方的除外状态把融合素材怪兽返回卡组作为代替
	local mg3 = nil
	local sg3 = nil
	if Duel.IsExistingMatchingCard(function(c) return c:GetOwner() ~= tp end, tp, LOCATION_MZONE, 0, 1, nil) then
		mg3 = Duel.GetMatchingGroup(cm.filter, tp, LOCATION_REMOVED, LOCATION_REMOVED, nil, nil, SUMMON_TYPE_FUSION, tp)
		mg1:Merge(mg3)
	end
	local sg1 = Duel.GetMatchingGroup(cm.fusionfilter, tp, LOCATION_EXTRA, 0, nil, e, tp, mg1, nil, chkf)
	local mg2 = nil
	local sg2 = nil
	local ce = Duel.GetChainMaterial(tp)
	if ce ~= nil then
		local fgroup = ce:GetTarget()
		mg2 = fgroup(ce, e, tp)
		local mf = ce:GetValue()
		sg2 = Duel.GetMatchingGroup(cm.fusionfilter, tp, LOCATION_EXTRA, 0, nil, e, tp, mg2, mf, chkf)
	end
	if sg1:GetCount() > 0 or (sg2 ~= nil and sg2:GetCount() > 0) or (sg3 ~= nil and sg3:GetCount() > 0) then
		local sg = sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		if sg3 then sg:Merge(sg3) end
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local tg = sg:Select(tp, 1, 1, nil)
		local tc = tg:GetFirst()
		if sg1:IsContains(tc) and (sg2 == nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp, ce:GetDescription())) then
			local mat1 = Duel.SelectFusionMaterial(tp, tc, mg1, nil, chkf)
			tc:SetMaterial(mat1)
			local g = mat1:Filter(Card.IsLocation, nil, LOCATION_REMOVED)
			mat1:Sub(g)
			if #g > 0 then
				Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT + REASON_MATERIAL + REASON_FUSION)
			end
			local num = Duel.SendtoGrave(mat1, REASON_EFFECT + REASON_MATERIAL + REASON_FUSION)
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

-- 旧②用函数（保留但未使用）
function cm.condition2(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	return re and
		re:GetHandler():IsSetCard(0x3e11)
end

function cm.filter2(c)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(cm.filter2, tp, LOCATION_GRAVE, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectTarget(tp, cm.filter2, tp, LOCATION_GRAVE, 0, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, tc)
	end
end

-- 新②的条件与效果
function cm.condition3(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	return re and
		re:GetHandler():IsSetCard(0x3e11) and bit.band(r, REASON_EFFECT) ~= 0
end

--② 目标：自己或对方卡组至少有2张可送，且自身可回手
function cm.tg3(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		local can_self = Duel.IsPlayerCanDiscardDeck(tp, 2)
		local can_opp  = Duel.IsPlayerCanDiscardDeck(1 - tp, 2)
		return (can_self or can_opp) and e:GetHandler():IsAbleToHand()
	end
	Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 2, tp, LOCATION_DECK)
	Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 2, 1 - tp, LOCATION_DECK)
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
end

--② 操作：从自己或对方卡组上面把2张卡送去墓地→这张卡加入手卡
function cm.op3(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local can_self = Duel.IsPlayerCanDiscardDeck(tp, 2)
	local can_opp  = Duel.IsPlayerCanDiscardDeck(1 - tp, 2)
	if not can_self and not can_opp then return end
	local send_self
	if can_self and can_opp then
		send_self = Duel.SelectOption(tp, aux.Stringid(m, 2), aux.Stringid(m, 3)) == 0
	else
		send_self = can_self
	end
	local target = send_self and tp or (1 - tp)
	Duel.DiscardDeck(target, 2, REASON_EFFECT)
	if c:IsRelateToEffect(e) and c:IsAbleToHand() then
		Duel.SendtoHand(c, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, c)
	end
end