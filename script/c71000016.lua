--大墓之埋葬者
-- 卡片类型：怪兽卡, 效果
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- 这个卡名的①②效果1回合各能使用1次。
	-- ①：从自己场上把1张卡送去墓地才能发动。这张卡从手卡特殊召唤。那之后，自己场上有对方怪兽的场合，可以再选场上1张卡送去墓地。这个回合，自己不是不死族怪兽不能从卡组特殊召唤。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_TOGRAVE + CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
	e1:SetCountLimit(1, m + 1)
	e1:SetCost(cm.cost1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡被效果送去墓地的场合，以自己墓地1张「大墓」陷阱卡为对象才能发动，那张卡盖放到自己场上。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1, m + 2)
	-- e2:SetCondition(cm.condition2)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

function cm.cost1(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then
		return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost, tp, LOCATION_HAND + LOCATION_ONFIELD, 0,
			1, e:GetHandler())
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g = Duel.SelectMatchingCard(tp, Card.IsAbleToGraveAsCost, tp, LOCATION_HAND + LOCATION_ONFIELD, 0, 1, 1,
		e:GetHandler())
	Duel.SendtoGrave(g, REASON_COST)
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
			c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, LOCATION_HAND)
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) then
		-- 这个回合，自己不是不死族怪兽不能从额外卡组特殊召唤
		local e1 = Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1, 0)
		e1:SetTarget(cm.splimit)
		e1:SetReset(RESET_PHASE + PHASE_END)
		Duel.RegisterEffect(e1, tp)
		-- 自己场上有对方怪兽的场合，可以再选场上1张卡送去墓地
		-- if Duel.IsExistingMatchingCard(function(c) return c:GetOwner() ~= tp end, tp, LOCATION_MZONE, 0, 1, nil) then
		-- 	if Duel.SelectYesNo(tp, aux.Stringid(m, 2)) then
		-- 		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
		-- 		local g = Duel.SelectMatchingCard(tp, Card.IsAbleToGrave, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1,
		-- 			nil)
		-- 		if #g > 0 then
		-- 			Duel.SendtoGrave(g, REASON_EFFECT)
		-- 		end
		-- 	end
		-- end
		if Duel.SelectYesNo(tp, aux.Stringid(m, 2)) then
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
			local g = Duel.SelectMatchingCard(tp, Card.IsType, tp, LOCATION_GRAVE, 0, 1, 1, nil, TYPE_MONSTER)
			if #g > 0 then
				Duel.SendtoHand(g, nil, REASON_EFFECT)
				Duel.ConfirmCards(1 - tp, g)
			end
		end
	end
end

function cm.splimit(e, c)
	return not c:IsRace(RACE_ZOMBIE) and c:IsLocation(LOCATION_EXTRA)
end

function cm.condition2(e, tp, eg, ep, ev, re, r, rp)
	return r & REASON_EFFECT ~= 0
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsSetCard(0x3e11) and
			chkc:IsType(TYPE_TRAP)
	end
	if chk == 0 then
		return Duel.IsExistingTarget(cm.filter, tp, LOCATION_GRAVE, 0, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
	local g = Duel.SelectTarget(tp, cm.filter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, g, 1, 0, 0)
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SSet(tp, tc)
		Duel.ConfirmCards(1 - tp, tc)
	end
end

function cm.filter(c)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
