--雨之魔女 芭万·希
function c72600210.initial_effect(c)
	aux.AddCodeList(c,72600200) 
	--change name
	aux.EnableChangeCode(c,72600200,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE) 
	--spsummon
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,72600210)
	e1:SetCondition(c72600210.spcon)
	e1:SetTarget(c72600210.sptg)
	e1:SetOperation(c72600210.spop)
	c:RegisterEffect(e1) 
	--token
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O) 
	e2:SetCode(EVENT_SPSUMMON_SUCCESS) 
	e2:SetProperty(EFFECT_FLAG_DELAY) 
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1) 
	e2:SetCondition(c72600210.tkcon)  
	e2:SetCost(c72600210.tkcost) 
	e2:SetTarget(c72600210.tktg)
	e2:SetOperation(c72600210.tkop)
	c:RegisterEffect(e2)  
	Duel.AddCustomActivityCounter(72600210,ACTIVITY_SPSUMMON,c72600210.counterfilter)
end
function c72600210.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) 
end
function c72600210.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_TOKEN) 
end
function c72600210.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c72600210.cfilter,1,nil,tp)
end
function c72600210.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c72600210.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) 
	end
end
function c72600210.tcfilter(c,tp)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsSummonPlayer(tp) 
end
function c72600210.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c72600210.tcfilter,1,nil,tp)
end 
function c72600210.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(72600210,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) 
	return not c:IsAttribute(ATTRIBUTE_DARK) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c72600210.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,72600209,nil,TYPES_TOKEN_MONSTER,0,0,4,RACE_FIEND,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
function c72600210.tkop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,72600209,nil,TYPES_TOKEN_MONSTER,0,0,4,RACE_FIEND,ATTRIBUTE_DARK) then return end
	local token=Duel.CreateToken(tp,72600209) 
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end




