--宁静的阳光午休
function c72600206.initial_effect(c)
	aux.AddCodeList(c,72600200)  
	--Activate
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_ACTIVATE) 
	e1:SetCode(EVENT_FREE_CHAIN)  
	c:RegisterEffect(e1)  
	--Avoid battle damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c)
	return c:IsCode(72600208,72600209) end)
	e1:SetValue(1)
	c:RegisterEffect(e1) 
	--SpecialSummon 
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O) 
	e2:SetCode(EVENT_DESTROYED) 
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP) 
	e2:SetRange(LOCATION_SZONE)   
	e2:SetCountLimit(1,72600206) 
	e2:SetCondition(c72600206.spcon)
	e2:SetTarget(c72600206.sptg)
	e2:SetOperation(c72600206.spop)
	c:RegisterEffect(e2) 
end
function c72600206.spckfil(c,tp) 
	return c:IsType(TYPE_TOKEN) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT+REASON_BATTLE)  
end 
function c72600206.spcon(e,tp,eg,ep,ev,re,r,rp)  
	return eg:IsExists(c72600206.spckfil,1,nil,tp)  
end  
function c72600206.filter(c,e,tp)
	return c:IsCode(72600200) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c72600206.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c72600206.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c72600206.spop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,c72600206.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst() 
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)  
	end
end









