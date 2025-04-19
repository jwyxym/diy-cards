--宇灾 痢疾癫兽
function c47700060.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,47700060) 
	e1:SetCost(c47700060.cost)
	e1:SetTarget(c47700060.thtg)
	e1:SetOperation(c47700060.thop)
	c:RegisterEffect(e1)
	--to hand 
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS) 
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,17700060) 
	e2:SetCondition(c47700060.fthcon)
	e2:SetCost(c47700060.fthcost)
	e2:SetTarget(c47700060.fthtg)
	e2:SetOperation(c47700060.fthop)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(47700060,ACTIVITY_SPSUMMON,c47700060.counterfilter)
end
function c47700060.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION)
end
function c47700060.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(47700060,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end 
function c47700060.thfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_PENDULUM) and (c:IsFaceup() or c:IsLocation(LOCATION_DECK)) and c:IsAbleToHand()
end
function c47700060.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c47700060.thfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function c47700060.psfilter(c)
	return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function c47700060.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c47700060.thfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		if (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and Duel.IsExistingMatchingCard(c47700060.psfilter,tp,LOCATION_HAND,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(47700060,0)) then
			Duel.BreakEffect() 
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local tc=Duel.SelectMatchingCard(tp,c47700060.psfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) 
		end 
	end
end
function c47700060.fckfil(c) 
	return c:IsType(TYPE_FUSION) and c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsFaceup() 
end 
function c47700060.fthcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47700060.fckfil,1,nil)
end 
function c47700060.fthcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(47700060,tp,ACTIVITY_SPSUMMON)==0 and aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) end 
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,1) 
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end 
function c47700060.fsfil(c,e,tp) 
	local mg=c:GetMaterial()
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and mg:IsExists(c47700060.fthfil,1,nil)
end 
function c47700060.fthfil(c)
	return c:IsLocation(LOCATION_GRAVE+LOCATION_EXTRA) and c:IsFaceup() and c:IsAbleToHand() and c:IsAttribute(ATTRIBUTE_DARK)
end 
function c47700060.fthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) 
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c47700060.fsfil(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(c47700060.fsfil,tp,LOCATION_MZONE,0,1,nil,e,tp) end 
	Duel.SelectTarget(tp,c47700060.fsfil,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end 
function c47700060.fthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local tc=Duel.GetFirstTarget() 
	local mg=tc:GetMaterial() 
	local smg=mg:Filter(c47700060.fthfil,nil) 
	if smg:GetCount()>0 then 
		local tc=smg:Select(tp,1,1,nil):GetFirst()
		Duel.SendtoHand(tc,tp,REASON_EFFECT) 
	end 
end 


