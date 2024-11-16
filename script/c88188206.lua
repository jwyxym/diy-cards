--Numerical lies
function c88188206.initial_effect(c)
	aux.AddSynchroMixProcedure(c,aux.Tuner(c88188206.sfilter1),nil,nil,aux.FilterBoolFunction(c88188206.sfilter2),1,99)
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.synlimit)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88188206,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,88188206)
	e1:SetTarget(c88188206.thtg)
	e1:SetOperation(c88188206.thop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(220414,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,88288206)
	e2:SetTarget(c88188206.target)
	e2:SetOperation(c88188206.operation)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_SET_ATTACK_FINAL)
	e3:SetValue(c88188206.atkval)
	c:RegisterEffect(e3)
end
c88188206.SetCard_Numerical_Crack=true
function c88188206.sfilter1(c)
	return c:IsSetCard(0xa590) and c:IsSynchroType(TYPE_SYNCHRO)
end
function c88188206.sfilter2(c)
	return c:IsRace(RACE_CYBERSE) and c:IsSynchroType(TYPE_SYNCHRO)
end
function c88188206.thfilter1(c,tp)
	return c.SetCard_Numerical_Crack and c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(c88188206.thfilter2,tp,LOCATION_GRAVE,0,1,nil,tp)
end
function c88188206.thfilter2(c,tp)
	return c.SetCard_Numerical_Crack and c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(c88188206.thfilter3,tp,LOCATION_REMOVED,0,1,nil,tp)
end
function c88188206.thfilter3(c,tp)
	return c.SetCard_Numerical_Crack and c:IsFaceup() and c:IsAbleToHand()
end
function c88188206.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c88188206.thfilter1,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.Hint(HINT_MESSAGE,1-tp,aux.Stringid(88188200,0))
	Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(88188200,0))
	Duel.RegisterFlagEffect(e:GetHandlerPlayer(),88188200,RESET_EVENT+RESETS_STANDARD,0,1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,3,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
function c88188206.thop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(c88188206.thfilter1,tp,LOCATION_DECK,0,1,nil,tp) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g1=Duel.SelectMatchingCard(tp,c88188206.thfilter1,tp,LOCATION_DECK,0,1,1,nil,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(tp,c88188206.thfilter2,tp,LOCATION_GRAVE,0,1,1,nil,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g3=Duel.SelectMatchingCard(tp,c88188206.thfilter3,tp,LOCATION_REMOVED,0,1,1,nil,tp)
		if g1:GetCount()>0 and g2:GetCount()>0 and g3:GetCount()>0 then
			Duel.SendtoHand(g1,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g1)
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g2)
			Duel.SendtoHand(g3,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g3)
		end
	end
end
function c88188206.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	local x=Duel.GetFlagEffect(e:GetHandlerPlayer(),88188200)
	if x>=10 then
		Duel.SetChainLimit(c88188206.chainlm)
	end
end
function c88188206.chainlm(e,ep,tp)
	return tp==ep
end
function c88188206.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_BATTLE)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetTargetRange(0,1)
	e2:SetValue(1)
	e2:SetReset(RESET_PHASE+PHASE_BATTLE)
	Duel.RegisterEffect(e2,tp)
end
function c88188206.atkval(e,c)
	local x=Duel.GetFlagEffect(e:GetHandlerPlayer(),88188200)
	return c:GetBaseAttack()*x*x*x
end