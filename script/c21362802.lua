--恶魔世界的激流
function c21362802.initial_effect(c)
	aux.AddCodeList(c,21362800)
	--pendulum set
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,21362802) 
	e1:SetTarget(c21362802.pctg)
	e1:SetOperation(c21362802.pcop)
	c:RegisterEffect(e1)
	--ctde 
	local e2=Effect.CreateEffect(c)  
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e2:SetCountLimit(1,11362802) 
	e2:SetCost(c21362802.ctdcost)
	e2:SetTarget(c21362802.ctdtg)
	e2:SetOperation(c21362802.ctdop)
	c:RegisterEffect(e2)
end
function c21362802.pcfilter(c)
	return c:IsCode(21362800) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function c21362802.spfil(c,e,tp) 
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)  
end 
function c21362802.pctg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local b1=(Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and Duel.IsExistingMatchingCard(c21362802.pcfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,nil,21362800) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c21362802.spfil,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end 
end
function c21362802.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local b1=(Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and Duel.IsExistingMatchingCard(c21362802.pcfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,nil,21362800) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c21362802.spfil,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	if b1 or b2 then 
		if b2 then 
			local sg=Duel.SelectMatchingCard(tp,c21362802.spfil,tp,LOCATION_GRAVE,0,1,1,nil,e,tp) 
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)  
		else  
			local tc=Duel.SelectMatchingCard(tp,c21362802.pcfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil):GetFirst()
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) 
		end 
	end
end
function c21362802.ctdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_COST) 
end
function c21362802.ctdfilter(c)
	return c:IsSetCard(0xba38) and c:IsAbleToHand()
end
function c21362802.ctdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,21362802)==0 end 
end
function c21362802.ctdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(21362802,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xba38))
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,21362802,RESET_PHASE+PHASE_END,0,1)
end



