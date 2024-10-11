--引祸上身的钓鱼
function c72600207.initial_effect(c) 
	aux.AddCodeList(c,72600200)  
	--token
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE) 
	e1:SetCode(EVENT_FREE_CHAIN)   
	e1:SetCountLimit(1,72600207+EFFECT_COUNT_CODE_OATH)  
	e1:SetTarget(c72600207.tktg)
	e1:SetOperation(c72600207.tkop)
	c:RegisterEffect(e1)   
end
function c72600207.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(72600207,tp,ACTIVITY_SPSUMMON)==0 end
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
function c72600207.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,72600208,nil,TYPES_TOKEN_MONSTER,500,500,4,RACE_AQUA,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
function c72600207.tkop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,72600208,nil,TYPES_TOKEN_MONSTER,500,500,4,RACE_AQUA,ATTRIBUTE_DARK) then return end
	local token=Duel.CreateToken(tp,72600208) 
	if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(72600200) end,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(function(c) return c:IsCode(72600205) and c:IsAbleToHand() end,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(72600207,0)) then 
		Duel.BreakEffect() 
		local sg=Duel.SelectMatchingCard(tp,function(c) return c:IsCode(72600205) and c:IsAbleToHand() end,tp,LOCATION_DECK,0,1,1,nil) 
		Duel.SendtoHand(sg,tp,REASON_EFFECT) 
		Duel.ConfirmCards(1-tp,sg)   
	end  
end





