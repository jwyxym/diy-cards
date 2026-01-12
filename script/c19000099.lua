--狐火御主
function c19000099.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE),4,2)
	c:EnableReviveLimit()
	--material
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(19000099,2))
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCountLimit(1)
	e0:SetTarget(c19000099.mttg)
	e0:SetOperation(c19000099.mtop)
	c:RegisterEffect(e0)
	--immune monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c19000099.econ)
	e1:SetValue(c19000099.efilter)
	c:RegisterEffect(e1)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c19000099.econ)
	e2:SetValue(1900)
	c:RegisterEffect(e2)
	--Return to Hand
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetCondition(c19000099.rhcon)
	e4:SetTarget(c19000099.rhtg)
	e4:SetOperation(c19000099.rhop)
	c:RegisterEffect(e4)
end
function c19000099.mtfilter(c,e)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAttack(1900) and c:IsCanOverlay()
end
function c19000099.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(c19000099.mtfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
end
function c19000099.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,c19000099.mtfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e)
	if g:GetCount()>0 then
		Duel.Overlay(c,g)
	end
end
function c19000099.econ(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,4,nil,19000027,19000030,19000074,19000075)
end
function c19000099.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function c19000099.rhcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,4,nil,19000027,19000030,19000074,19000075) and Duel.GetAttacker()==e:GetHandler()
end
function c19000099.rhtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD+LOCATION_REMOVED+LOCATION_HAND+LOCATION_GRAVE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD+LOCATION_REMOVED+LOCATION_HAND+LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
function c19000099.rhop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD+LOCATION_REMOVED+LOCATION_HAND+LOCATION_GRAVE,nil)
	if g:GetCount()>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_RULE)
	end
end