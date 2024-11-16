--Numerical growers
function c88188211.initial_effect(c)
	aux.AddSynchroMixProcedure(c,aux.Tuner(Card.IsSetCard,0xa590),nil,nil,aux.FilterBoolFunction(Card.IsRace,RACE_CYBERSE),1,99)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88188211,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,88188211)
	e1:SetCondition(c88188211.thcon)
	e1:SetTarget(c88188211.thtg)
	e1:SetOperation(c88188211.thop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88188211,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,88288211)
	e2:SetCondition(c88188211.sccon)
	e2:SetTarget(c88188211.sctg)
	e2:SetOperation(c88188211.scop)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_SET_ATTACK_FINAL)
	e3:SetValue(c88188211.atkval)
	c:RegisterEffect(e3)
end
c88188211.SetCard_Numerical_Crack=true
function c88188211.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function c88188211.thfilter(c)
	return c:IsSetCard(0xa590) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c88188211.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c88188211.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_MESSAGE,1-tp,aux.Stringid(88188200,0))
	Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(88188200,0))
	Duel.RegisterFlagEffect(e:GetHandlerPlayer(),88188200,RESET_EVENT+RESETS_STANDARD,0,1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c88188211.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c88188211.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c88188211.sccon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return not e:GetHandler():IsStatus(STATUS_CHAINING)
		and (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
function c88188211.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c88188211.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
function c88188211.atkval(e,c)
	local x=Duel.GetFlagEffect(e:GetHandlerPlayer(),88188200)
	return c:GetBaseAttack()*x*x
end