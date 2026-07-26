--异质绝望的仆役
function c35100149.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,c35100149.matfilter,1,1)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,35100149)
	e1:SetCondition(c35100149.spcon)
	e1:SetTarget(c35100149.sptg)
	e1:SetOperation(c35100149.spop)
	c:RegisterEffect(e1)
	--Negate
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,35100150)
	e2:SetCondition(c35100149.discon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c35100149.distg)
	e2:SetOperation(c35100149.disop)
	c:RegisterEffect(e2)
end
function c35100149.matfilter(c)
	return c:IsLinkSetCard(0xa91) and not c:IsLinkCode(35100149)
end
function c35100149.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c35100149.spfilter(c,e,tp)
	return c:IsSetCard(0xa91) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c35100149.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c35100149.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c35100149.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c35100149.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Damage(tp,tc:GetLevel()*200,REASON_EFFECT)
	end
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c35100149.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c35100149.splimit(e,c)
	return not c:IsRace(RACE_WARRIOR) and c:IsLocation(LOCATION_EXTRA)
end
function c35100149.cfilter(c)
	return c:IsSetCard(0xa91) and c:IsFaceup()
end
function c35100149.discon(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsExistingMatchingCard(c35100149.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	return rp==1-tp and re:IsHasCategory(CATEGORY_SPECIAL_SUMMON)
end
function c35100149.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c35100149.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end