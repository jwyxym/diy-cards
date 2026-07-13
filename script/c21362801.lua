--恶魔世界的润育
function c21362801.initial_effect(c)
	aux.AddCodeList(c,21362800)
	--pendulum set
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,21362801) 
	e1:SetTarget(c21362801.pctg)
	e1:SetOperation(c21362801.pcop)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e2:SetCountLimit(1,11362801) 
	e2:SetCost(c21362801.thcost)
	e2:SetTarget(c21362801.thtg)
	e2:SetOperation(c21362801.thop)
	c:RegisterEffect(e2)
end
function c21362801.pcfilter(c)
	return c:IsCode(21362800) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function c21362801.pctg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local b1=(Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and Duel.IsExistingMatchingCard(c21362801.pcfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,nil,21362800)
	if chk==0 then return b1 or b2 end
end
function c21362801.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local b1=(Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and Duel.IsExistingMatchingCard(c21362801.pcfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,nil,21362800)
	if b1 or b2 then 
		if b2 then 
			Duel.Recover(tp,2500,REASON_EFFECT) 
		else  
			local tc=Duel.SelectMatchingCard(tp,c21362801.pcfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil):GetFirst()
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) 
		end 
	end
end
function c21362801.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_COST) 
end
function c21362801.thfilter(c)
	return c:IsSetCard(0xba38) and c:IsAbleToHand()
end
function c21362801.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21362801.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c21362801.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c21362801.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end





