--
function c20020013.initial_effect(c)
	c:SetSPSummonOnce(20020013)
	--synchro summon
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xb35),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	--special summon
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(20020013,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCountLimit(1,20020013)
	e0:SetCondition(c20020013.spcon)
	e0:SetTarget(c20020013.sptg)
	e0:SetOperation(c20020013.spop)
	c:RegisterEffect(e0)
	c20020013.sps_effect=e0
	--pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	--activate cost
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_ACTIVATE_COST)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetCost(c20020013.costchk)
	e3:SetOperation(c20020013.costop)
	c:RegisterEffect(e3)
	--accumulate
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_FLAG_EFFECT+20020013)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(0,1)
	c:RegisterEffect(e4)
end
function c20020013.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function c20020013.spfilter(c,e,tp)
	return c:IsSetCard(0xb35) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c20020013.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c20020013.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c20020013.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c20020013.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c20020013.costchk(e,te_or_c,tp)
	local ct=Duel.GetFlagEffect(tp,20020013)
	return Duel.CheckLPCost(tp,ct*500)
end
function c20020013.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,500)
end