--魔女结界
function c38030088.initial_effect(c)
	c:EnableCounterPermit(0x610)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--counter
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(c38030088.ctcon)
	e1:SetOperation(c38030088.ctop)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(1190)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,38030088)
	e2:SetCost(c38030088.thcost)
	e2:SetTarget(c38030088.thtg)
	e2:SetOperation(c38030088.thop)
	c:RegisterEffect(e2)
	--salvage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(1190)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(c38030088.cost)
	e3:SetTarget(c38030088.target)
	e3:SetOperation(c38030088.operation)
	c:RegisterEffect(e3)
end
function c38030088.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSetCard(0x615) and c:IsFaceup()
end
function c38030088.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c38030088.cfilter,1,nil,tp)
end
function c38030088.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x610,1)
end
function c38030088.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x610,3,REASON_COST) end
	Duel.RemoveCounter(tp,1,1,0x610,3,REASON_COST)
end
function c38030088.thfilter(c)
	return c:IsSetCard(0x615) and c:IsType(TYPE_MONSTER) and  (c:IsAbleToHand() or c:IsAbleToGrave())
end
function c38030088.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c38030088.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c38030088.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,c38030088.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	else
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
function c38030088.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x610,2,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x610,2,REASON_COST)
end
function c38030088.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function c38030088.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end
