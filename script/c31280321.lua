--深池的行军
function c31280321.initial_effect(c)
	--仪式召唤
	aux.AddRitualProcGreater2(c,c31280321.ritual_filter)
    --卡组检索
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,31280321)
	e1:SetCondition(c31280321.condition)
    e1:SetCost(aux.bfgcost)
	e1:SetTarget(c31280321.target)
	e1:SetOperation(c31280321.operation)
	c:RegisterEffect(e1)
	if not c31280321.global_check then
		c31280321.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
        ge1:SetCondition(c31280321.checkcon)
		ge1:SetOperation(c31280321.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function c31280321.ritual_filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsSetCard(0xca3) and not c:IsRace(RACE_ZOMBIE)
end
function c31280321.checkfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_RITUAL) and c:IsRace(RACE_DRAGON)
end    
function c31280321.checkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31280321.checkfilter,1,nil)
end
function c31280321.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c31280321.checkfilter,1,nil)
	local tc=g:GetFirst()
	while tc do
		if Duel.GetFlagEffect(tc:GetSummonPlayer(),31280321)==0 then
			Duel.RegisterFlagEffect(tc:GetSummonPlayer(),31280321,RESET_PHASE+PHASE_END,0,1)
		end
		if Duel.GetFlagEffect(0,31280321)>0 and Duel.GetFlagEffect(1,31280321)>0 then
			break
		end
		tc=g:GetNext()
	end
end
function c31280321.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,31280321)>0
end
function c31280321.thfilter(c)
	return c:IsSetCard(0xca3) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c31280321.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280321.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c31280321.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c31280321.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
    end   
end