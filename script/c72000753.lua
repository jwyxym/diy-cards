--冰炎世界-绝对零度
function c72000753.initial_effect(c)
	aux.AddCodeList(c,72000753)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,72000753)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCost(c72000753.thcost)
	e1:SetTarget(c72000753.thtg)
	e1:SetOperation(c72000753.thop)
	c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72000753,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetTarget(c72000753.sumtg)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(72000753,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,72000753)
	e3:SetCondition(c72000753.tgcon)
	e3:SetOperation(c72000753.tgop)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(72000753,ACTIVITY_SPSUMMON,c72000753.counterfilter)
end
function c72000753.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsRace(RACE_FAIRY | RACE_WINDBEAST | RACE_WARRIOR) and c:IsType(TYPE_XYZ)
end
function c72000753.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(72000753,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c72000753.splimit)
	Duel.RegisterEffect(e1,tp)
end
function c72000753.thfilter(c)
	return c:IsAbleToHand() and aux.IsCodeListed(c,72000753) and not c:IsCode(72000753)
end
function c72000753.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
   if chk==0 then return Duel.IsExistingMatchingCard(c72000753.thfilter,tp,LOCATION_DECK,0,1,nil) end
   Duel.SetOperationInfo(0,CATEGORY_TOHAND+CATEGORY_SEARCH,nil,1,tp,LOCATION_DECK)
end
function c72000753.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,c72000753.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #tc>0 then
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
function c72000753.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_FAIRY+RACE_WINDBEAST+RACE_WARRIOR) and c:IsType(TYPE_XYZ))
end
function c72000753.sumtg(e,c)
	return c:IsRace(RACE_WINDBEAST) and c:IsAttribute(ATTRIBUTE_WATER)
end
function c72000753.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local a,d=Duel.GetBattleMonster(tp)
	if a and d and a:IsFaceup() and a:IsAttribute(ATTRIBUTE_WATER) and a:IsType(TYPE_XYZ) then
		return true
	else return false end
end
function c72000753.tgfilter(c)
	return c:GetOverlayCount()==0
end
function c72000753.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c72000753.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		if tc:IsFaceup() then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(0)
			tc:RegisterEffect(e1)
		end
	end
end
