--大墓之行刑者
-- 卡片类型：怪兽卡, 效果, 融合
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- 「大墓」怪兽×2
	-- 这个卡名的①②效果1回合各能使用1次。
	c:EnableReviveLimit()
	-- 融合召唤条件
	aux.AddFusionProcMix(c, true, true, cm.ffilter, cm.ffilter)

	-- ①：自己场上有对方怪兽的场合，把自己场上1张卡送去墓地才能发动。选场上1张卡送去墓地或除外。这个效果在对方回合也能发动。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_TOGRAVE + CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1, m + 1)
	e1:SetCost(cm.cost1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡被效果送去墓地的场合，以除外状态的1只对方怪兽为对象才能发动。那只怪兽在自己场上特殊召唤，效果无效，攻击力·守备力变成0。那只怪兽不能作为融合·同调·超量·连接召唤的素材。
	-- local e2 = Effect.CreateEffect(c)
	-- e2:SetDescription(aux.Stringid(m, 1))
	-- e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	-- e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	-- e2:SetCode(EVENT_TO_GRAVE)
	-- e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
	-- e2:SetCountLimit(1, m + 2)
	-- e2:SetCondition(cm.condition2)
	-- e2:SetTarget(cm.tg2)
	-- e2:SetOperation(cm.op2)
	-- c:RegisterEffect(e2)

	--②：这张卡被除外的场合，以场上1张卡为对象才能发动。那张卡破坏，破坏的是怪兽的场合，那只怪兽效果无效并在自己场上特殊召唤，攻击力·守备力变成0。那只怪兽不能作为融合·同调·超量·连接召唤的素材。
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m, 4))
	e3:SetCategory(CATEGORY_DESTROY + CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1, m + 3)
	e3:SetTarget(cm.tg3)
	e3:SetOperation(cm.op3)
	c:RegisterEffect(e3)
end

function cm.ffilter(c, fc, sumtype, tp)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_MONSTER)
end

function cm.filter2(c, tp)
	return c:IsType(TYPE_MONSTER) and c:GetOwner() == 1 - tp
end

function cm.cost1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost, tp, LOCATION_ONFIELD, 0, 1, nil) and
			Duel.IsExistingMatchingCard(cm.filter2, tp, LOCATION_MZONE, 0, 1, nil, tp)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g = Duel.SelectMatchingCard(tp, Card.IsAbleToGraveAsCost, tp, LOCATION_ONFIELD, 0, 1, 1, nil)
	Duel.SendtoGrave(g, REASON_COST)
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(Card.IsAbleToGrave, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1,
			nil)
	end
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
	local opt = Duel.SelectOption(tp, aux.Stringid(m, 2), aux.Stringid(m, 3))
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_OPERATECARD)
	local g = Duel.SelectMatchingCard(tp, opt == 0 and Card.IsAbleToGrave or Card.IsAbleToRemove, tp, LOCATION_ONFIELD,
		LOCATION_ONFIELD, 1, 1, nil)
	if #g > 0 then
		if opt == 0 then
			Duel.SendtoGrave(g, REASON_EFFECT)
		else
			Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
		end
	end
end

function cm.condition2(e, tp, eg, ep, ev, re, r, rp)
	return r & REASON_EFFECT ~= 0 and
		Duel.IsExistingMatchingCard(Card.IsControler, tp, 0, LOCATION_REMOVED, 1, nil, 1 - tp)
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(1 - tp) and
			chkc:IsCanBeSpecialSummoned(e, 0, tp, false, false)
	end
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
			Duel.IsExistingTarget(Card.IsCanBeSpecialSummoned, tp, 0, LOCATION_REMOVED, 1, nil, e, 0, tp, false, false)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectTarget(tp, Card.IsCanBeSpecialSummoned, tp, 0, LOCATION_REMOVED, 1, 1, nil, e, 0, tp, false,
		false)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	if Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
		-- 效果无效
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2 = e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
		-- 攻击力·守备力变成0
		local e3 = Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetValue(0)
		e3:SetReset(RESET_EVENT + RESETS_STANDARD)
		tc:RegisterEffect(e3)
		local e4 = e3:Clone()
		e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e4)
		-- 不能作为融合·同调·超量·连接召唤的素材
		local e5 = Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e5:SetValue(1)
		e5:SetReset(RESET_EVENT + RESETS_STANDARD)
		tc:RegisterEffect(e5)
		local e6 = e5:Clone()
		e6:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		tc:RegisterEffect(e6)
		local e7 = e5:Clone()
		e7:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		tc:RegisterEffect(e7)
		local e8 = e5:Clone()
		e8:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		tc:RegisterEffect(e8)
	end
	Duel.SpecialSummonComplete()
end

function cm.tg3(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then
		return chkc:IsOnField() and chkc:IsLocation(LOCATION_ONFIELD)
	end
	if chk == 0 then
		return Duel.IsExistingTarget(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
	local g = Duel.SelectTarget(tp, aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function cm.op3(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if Duel.Destroy(tc, REASON_EFFECT) == 0 then return end
	-- 破坏的是怪兽的场合，特殊召唤
	if not tc:IsType(TYPE_MONSTER) then return end
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	if Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
		-- 效果无效
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e1b = e1:Clone()
		e1b:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e1b)
		-- 攻击力·守备力变成0
		local e2 = Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetValue(0)
		e2:SetReset(RESET_EVENT + RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e2b = e2:Clone()
		e2b:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e2b)
		-- 不能作为融合·同调·超量·连接召唤的素材
		local e3 = Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT + RESETS_STANDARD)
		tc:RegisterEffect(e3)
		local e3b = e3:Clone()
		e3b:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		tc:RegisterEffect(e3b)
		local e3c = e3:Clone()
		e3c:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		tc:RegisterEffect(e3c)
		local e3d = e3:Clone()
		e3d:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		tc:RegisterEffect(e3d)
	end
	Duel.SpecialSummonComplete()
end
