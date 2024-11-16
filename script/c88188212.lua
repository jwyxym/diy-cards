--Numerical calculators
function c88188212.initial_effect(c)
	aux.AddSynchroMixProcedure(c,aux.Tuner(Card.IsSetCard,0xa590),nil,nil,aux.FilterBoolFunction(c88188212.sfilter),1,99)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88188212,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,88188212)
	e1:SetCondition(c88188212.thcon)
	e1:SetTarget(c88188212.thtg)
	e1:SetOperation(c88188212.thop)
	c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88188212,1))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,88288212)
	e1:SetCondition(c88188212.spcon)
	e1:SetTarget(c88188212.sptg)
	e1:SetOperation(c88188212.spop)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_SET_ATTACK_FINAL)
	e3:SetValue(c88188212.atkval)
	c:RegisterEffect(e3)
end
c88188212.SetCard_Numerical_Crack=true
function c88188212.sfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsSynchroType(TYPE_SYNCHRO)
end
function c88188212.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function c88188212.thfilter(c)
	return c.SetCard_Numerical_Crack and c:IsAbleToHand()
end
function c88188212.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c88188212.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_MESSAGE,1-tp,aux.Stringid(88188200,0))
	Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(88188200,0))
	Duel.RegisterFlagEffect(e:GetHandlerPlayer(),88188200,RESET_EVENT+RESETS_STANDARD,0,1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c88188212.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c88188211.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c88188212.spcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	if a:IsControler(1-tp) then return false end
	return a:IsFaceup() and a:IsSetCard(0xa590)
end
function c88188212.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	Duel.SetTargetCard(Duel.GetAttacker())
end
function c88188212.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
	end
end
function c88188212.atkval(e,c)
	local x=Duel.GetFlagEffect(e:GetHandlerPlayer(),88188200)
	return c:GetBaseAttack()*x*x
end