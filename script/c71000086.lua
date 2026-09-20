--大墓之钩魂链
-- 卡片类型：陷阱卡, 永续
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- 永续陷阱效果
	local e0 = Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- ①：对方场上的怪兽被送去墓地或除外的场合，以那只怪兽为对象才能发动。那只怪兽效果无效并特殊召唤到自己场上，攻击力·守备力变为0，不能作为融合·同调·超量·链接的素材。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1, m + 1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
	-- e1:SetCondition(cm.condition1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	local e1b = e1:Clone()
	e1b:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e1b)

	-- ②：这张卡从场上或被「大墓」卡的效果送去墓地的场合才能发动。从自己的卡组选1张「大墓」魔法卡加入手卡。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1, m + 2)
	e2:SetCondition(cm.condition2)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

function cm.condition1(e, tp, eg, ep, ev, re, r, rp)
	return eg:IsExists(Card.IsControler, 1, nil, 1 - tp) and
		eg:IsExists(function(c)
			return c:IsType(TYPE_MONSTER)
		end
		, 1, nil)
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then
		return (chkc:IsLocation(LOCATION_REMOVED) or chkc:IsLocation(LOCATION_GRAVE)) and chkc:IsControler(1 - tp) and
			chkc:IsType(TYPE_MONSTER) and chkc:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
			eg:IsContains(chkc)
	end
	if chk == 0 then
		return Duel.IsExistingMatchingCard(cm.filter, tp, 0, LOCATION_GRAVE + LOCATION_REMOVED, 1, nil, e, tp, eg) and
			Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
	local g = Duel.SelectMatchingCard(tp, cm.filter, tp, 0, LOCATION_GRAVE + LOCATION_REMOVED, 1, 1, nil, e, tp, eg)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function cm.filter(c, e, tp, eg)
	return c:IsType(TYPE_MONSTER) and c:IsControler(1 - tp) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
		eg:IsContains(c) and (c:IsPreviousLocation(LOCATION_MZONE) or c:IsPreviousLocation(LOCATION_SZONE))
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
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
		e2:SetCode(EFFECT_DISABLE)
		tc:RegisterEffect(e2)
		-- 攻击力·守备力变为0
		local e3 = Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetValue(0)
		e3:SetReset(RESET_EVENT + RESETS_STANDARD)
		tc:RegisterEffect(e3)
		local e4 = e3:Clone()
		e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e4)
		-- 不能作为融合·同调·超量·链接的素材
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

function cm.condition2(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and
		(c:IsPreviousLocation(LOCATION_ONFIELD) or (r & REASON_EFFECT ~= 0 and re and re:GetHandler():IsSetCard(0x3e11)))
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(cm.filter2, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function cm.filter2(c)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, cm.filter2, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, g)
	end
end
