--恶魔世界的烈焰
function c21362803.initial_effect(c)
	aux.AddCodeList(c,21362800)
	--pendulum set
	local e1=Effect.CreateEffect(c)  
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,21362803) 
	e1:SetTarget(c21362803.pctg)
	e1:SetOperation(c21362803.pcop)
	c:RegisterEffect(e1)
	--ctde 
	local e2=Effect.CreateEffect(c)  
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e2:SetCountLimit(1,11362803) 
	e2:SetCost(c21362803.ctdcost)
	e2:SetTarget(c21362803.ctdtg)
	e2:SetOperation(c21362803.ctdop)
	c:RegisterEffect(e2)
end
function c21362803.pcfilter(c)
	return c:IsCode(21362800) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function c21362803.spfil(c,e,tp) 
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)  
end 
function c21362803.pctg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local b1=(Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and Duel.IsExistingMatchingCard(c21362803.pcfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,nil,21362800) and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 end 
end
function c21362803.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local b1=(Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and Duel.IsExistingMatchingCard(c21362803.pcfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,nil,21362800) and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil)
	if b1 or b2 then 
		if b2 then 
			local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,1,nil) 
			Duel.SendtoGrave(sg,REASON_EFFECT) 
		else  
			local tc=Duel.SelectMatchingCard(tp,c21362803.pcfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil):GetFirst()
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)  
		end 
	end
end
function c21362803.ctdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_COST) 
end
function c21362803.ctdfilter(c)
	return c:IsSetCard(0xba38) and c:IsAbleToHand()
end
function c21362803.ctdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end 
end
function c21362803.ctdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(e:GetHandler()) 
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xba38))
	e1:SetValue(1500)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp) 
end




