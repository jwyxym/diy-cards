--
function c20100016.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,20100016)
	e1:SetCost(c20100016.thcost)
	e1:SetTarget(c20100016.thtg)
	e1:SetOperation(c20100016.thop)
	c:RegisterEffect(e1)
	--destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c20100016.reptg)
	e2:SetValue(c20100016.repval)
	e2:SetOperation(c20100016.repop)
	c:RegisterEffect(e2)
end
function c20100016.thcfilter(c)
	return c:IsSetCard(0xb28) and c:IsDiscardable()
end
function c20100016.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20100016.thcfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,c20100016.thcfilter,1,1,REASON_COST+REASON_DISCARD)
end
function c20100016.thfilter(c)
	return c:IsSetCard(0xb28) and c:IsFaceupEx() and c:IsAbleToHand() and not c:IsCode(20100016)
end
function c20100016.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20100016.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function c20100016.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c20100016.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c20100016.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xb28) and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
function c20100016.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c20100016.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function c20100016.repval(e,c)
	return c20100016.repfilter(c,e:GetHandlerPlayer())
end
function c20100016.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end