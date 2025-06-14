--触手危机
function c72600205.initial_effect(c) 
	aux.AddCodeList(c,72600200)  
	--Activate
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_ACTIVATE) 
	e1:SetCode(EVENT_FREE_CHAIN)  
	c:RegisterEffect(e1) 
	--token
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_QUICK_O) 
	e1:SetCode(EVENT_FREE_CHAIN) 
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE) 
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,72600205) 
	e1:SetCondition(c72600205.tkcon)  
	e1:SetTarget(c72600205.tktg)
	e1:SetOperation(c72600205.tkop)
	c:RegisterEffect(e1)   
	--atk 
	local e2=Effect.CreateEffect(c)  
	e2:SetType(EFFECT_TYPE_FIELD) 
	e2:SetCode(EFFECT_UPDATE_ATTACK) 
	e2:SetRange(LOCATION_SZONE) 
	e2:SetTargetRange(LOCATION_MZONE,0) 
	e2:SetTarget(function(e,c) 
	return c:IsCode(72600208) end) 
	e2:SetValue(2000) 
	c:RegisterEffect(e2) 
	local e3=e2:Clone() 
	e3:SetCode(EFFECT_UPDATE_DEFENSE) 
	c:RegisterEffect(e3) 
end
function c72600205.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(72600200) end,tp,LOCATION_MZONE,0,1,nil) 
end
function c72600205.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,72600208,nil,TYPES_TOKEN_MONSTER,500,500,4,RACE_SPELLCASTER,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
function c72600205.tkop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,72600208,nil,TYPES_TOKEN_MONSTER,500,500,4,RACE_SPELLCASTER,ATTRIBUTE_DARK) then return end
	local token=Duel.CreateToken(tp,72600208) 
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end