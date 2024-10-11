--迅装上阵
function c72600204.initial_effect(c) 
	aux.AddCodeList(c,72600200) 
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)  
	e1:SetCountLimit(1,72600204) 
	e1:SetTarget(c72600204.target)
	e1:SetOperation(c72600204.activate)
	c:RegisterEffect(e1) 
	--token
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION) 
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,72600204) 
	e2:SetCondition(c72600204.tkcon) 
	e2:SetCost(aux.bfgcost) 
	e2:SetTarget(c72600204.tktg)
	e2:SetOperation(c72600204.tkop)
	c:RegisterEffect(e2)
end 
function c72600204.filter(c,e,tp)
	return c:IsCode(72600200) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c72600204.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(72600204,tp,ACTIVITY_SPSUMMON)==0 end
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
function c72600204.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c72600204.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c72600204.activate(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,c72600204.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst() 
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) 
		--indes
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetRange(LOCATION_MZONE) 
		e1:SetValue(1) 
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END) 
		tc:RegisterEffect(e1)
	end
end
function c72600204.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(72600200) end,tp,LOCATION_MZONE,0,1,nil) 
end
function c72600204.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,72600208,nil,TYPES_TOKEN_MONSTER,500,500,4,RACE_AQUA,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
function c72600204.tkop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,72600208,nil,TYPES_TOKEN_MONSTER,500,500,4,RACE_AQUA,ATTRIBUTE_DARK) then return end
	local token=Duel.CreateToken(tp,72600208) 
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end

