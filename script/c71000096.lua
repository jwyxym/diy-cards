--大墓之裁定者
-- 卡片类型：怪兽卡, 效果, 融合
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- 「大墓」怪兽×2
	-- 这个卡名的①②效果1回合各能使用1次。
	c:EnableReviveLimit()
	aux.AddFusionProcMix(c, true, true, cm.ffilter, cm.ffilter)

	-- ①：这张卡融合召唤成功的场合，以对方场上或墓地1张卡为对象才能发动。那张卡除外。那之后，可以从自己墓地把1只「大墓」卡除外。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1, m + 1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
	-- e1:SetCondition(cm.spcon1)
	e1:SetTarget(cm.rmtg1)
	e1:SetOperation(cm.rmop1)
	c:RegisterEffect(e1)

	-- ②：这张卡被送去墓地的场合，以除外状态的1张自己的「大墓」卡为对象才能发动。那张卡回到墓地。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1, m + 2)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
	e2:SetTarget(cm.tgtg2)
	e2:SetOperation(cm.tgop2)
	c:RegisterEffect(e2)
end

function cm.ffilter(c)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_MONSTER)
end

function cm.spcon1(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function cm.rmfilter1(c, tp)
	return (c:IsLocation(LOCATION_ONFIELD) or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToRemove(tp)
end

function cm.rmtg1(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsControler(1 - tp) and cm.rmfilter1(chkc, tp) end
	if chk == 0 then return Duel.IsExistingTarget(cm.rmfilter1, tp, 0, LOCATION_ONFIELD + LOCATION_GRAVE, 1, nil, tp) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local g = Duel.SelectTarget(tp, cm.rmfilter1, tp, 0, LOCATION_ONFIELD + LOCATION_GRAVE, 1, 1, nil, tp)
	Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, 0, 0)
end

function cm.rmfilter2(c)
	return c:IsSetCard(0x3e11) and c:IsAbleToRemove()
end

function cm.rmop1(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc, POS_FACEUP, REASON_EFFECT) ~= 0 then
		-- 那之后，可以从自己墓地把1只「大墓」卡除外。
		local g = Duel.GetMatchingGroup(cm.rmfilter2, tp, LOCATION_GRAVE, 0, nil)
		if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(m, 2)) then
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
			local sg = g:Select(tp, 1, 1, nil)
			Duel.Remove(sg, POS_FACEUP, REASON_EFFECT)
		end
	end
end

function cm.tgfilter2(c, tp)
	return c:IsSetCard(0x3e11) and c:IsControler(tp) and c:IsLocation(LOCATION_REMOVED) and c:IsAbleToGrave()
end

function cm.tgtg2(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsControler(tp) and cm.tgfilter2(chkc, tp) end
	if chk == 0 then return Duel.IsExistingTarget(cm.tgfilter2, tp, LOCATION_REMOVED, 0, 1, nil, tp) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g = Duel.SelectTarget(tp, cm.tgfilter2, tp, LOCATION_REMOVED, 0, 1, 1, nil, tp)
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, 1, 0, 0)
end

function cm.tgop2(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc, REASON_EFFECT)
	end
end
