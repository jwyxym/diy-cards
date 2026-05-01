--狂恋的恋姬
function c16820940.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xdf97),5,2)
	c:EnableReviveLimit()
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,16820940)
	e1:SetCondition(c16820940.discon)
	e1:SetCost(c16820940.discost)
	e1:SetTarget(c16820940.distg)
	e1:SetOperation(c16820940.disop)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,16820940+1)
	e2:SetCondition(c16820940.con)
	e2:SetCost(c16820940.cost)
	e2:SetTarget(c16820940.tg)
	e2:SetOperation(c16820940.op)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	c:RegisterEffect(e3)
end
function c16820940.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function c16820940.costfilter(c,tp)
	return c:IsAbleToGraveAsCost() and c:IsFaceupEx() and not c:IsCode(16820940)
		and Duel.IsExistingMatchingCard(c16820940.disfilter,tp,0xc,0xc,1,nil,c:GetType()&0x7)
end
function c16820940.disfilter(c,type)
	return aux.NegateAnyFilter(c) and (c:GetType()&0x7)==type and not c:IsCode(16820940)
end
function c16820940.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST)
		and Duel.IsExistingMatchingCard(c16820940.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,c,tp) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c16820940.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,c,tp)
	Duel.SendtoGrave(g,REASON_COST)
	local tc=g:GetFirst()
	e:SetLabel(tc:GetType()&0x7)
end
function c16820940.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function c16820940.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local type=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	local g=Duel.SelectMatchingCard(tp,c16820940.disfilter,tp,0xc,0xc,1,1,nil,type)
	local tc=g:GetFirst()
	if tc and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetCondition(c16820940.rcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc:RegisterEffect(e2)
		end
	end
end
function c16820940.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
function c16820940.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated()
end
function c16820940.costfilter2(c)
	return c:IsSetCard(0xdf97) and c:IsAbleToGraveAsCost()
end
function c16820940.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c16820940.costfilter2,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c16820940.costfilter2,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function c16820940.filter(c)
	return c:IsSetCard(0xdf97) and c:IsAbleToHand()
end
function c16820940.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c16820940.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function c16820940.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16820940.filter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end