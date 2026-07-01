--墨染乐章 织梦
function c21301009.initial_effect(c)
	--sp 
	local e1=Effect.CreateEffect(c)  
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,21301009)
	e1:SetTarget(c21301009.settg)
	e1:SetOperation(c21301009.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)  
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE) 
	c:RegisterEffect(e2)	
	c21301009.remove_effect=e2  
	--to hand 
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TOHAND) 
	e2:SetType(EFFECT_TYPE_QUICK_O) 
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,21301010) 
	e2:SetCondition(function(e) 
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2 end) 
	e2:SetCost(c21301009.thcost)
	e2:SetTarget(c21301009.thtg)
	e2:SetOperation(c21301009.thop)
	c:RegisterEffect(e2) 
end
function c21301009.setfilter(c)
	return c:IsSetCard(0x682) and c:IsSSetable() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c21301009.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21301009.setfilter,tp,LOCATION_DECK,0,1,nil) end 
end
function c21301009.setop(e,tp,eg,ep,ev,re,r,rp)   
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,c21301009.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SSet(tp,tc)~=0 then 
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(21301009,0))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function c21301009.ctfil(c) 
	return c:IsAbleToRemoveAsCost() and c:IsSetCard(0x682)   
end 
function c21301009.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21301009.ctfil,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end  
	local g=Duel.SelectMatchingCard(tp,c21301009.ctfil,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil) 
	Duel.Remove(g,POS_FACEUP,REASON_COST) 
end
function c21301009.thfil(c) 
	return c:IsFaceup() and c:IsSetCard(0x682) and c:IsAbleToHand()   
end 
function c21301009.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21301009.thfil,tp,LOCATION_REMOVED,0,1,nil) end  
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function c21301009.thop(e,tp,eg,ep,ev,re,r,rp)   
	local c=e:GetHandler()
	local tc=Duel.SelectMatchingCard(tp,c21301009.thfil,tp,LOCATION_REMOVED,0,1,1,nil):GetFirst() 
	if tc then 
		Duel.SendtoHand(tc,nil,REASON_EFFECT) 
	end 
end 
