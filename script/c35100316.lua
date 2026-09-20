--宝伞象征 猛虎扑食
function c35100316.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,35100316+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c35100316.target)
	e1:SetOperation(c35100316.activate)
	c:RegisterEffect(e1)
    --to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,35100317)
	e2:SetCondition(c35100316.thcon)
	e2:SetTarget(c35100316.thtg)
	e2:SetOperation(c35100316.thop)
	c:RegisterEffect(e2)
    Duel.AddCustomActivityCounter(35100316,ACTIVITY_CHAIN,c35100316.chainfilter)
end
function c35100316.chainfilter(re,tp,cid)
	local ph=Duel.GetCurrentPhase()
	return not (re:IsActiveType(TYPE_MONSTER) and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)))
end
function c35100316.filter(c,e,tp)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c35100316.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c35100316.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c35100316.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	if ft>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and Duel.GetCustomActivityCount(35100316,1-tp,ACTIVITY_CHAIN)~=0 then
		ft=2
	else
		ft=1
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c35100316.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,ft,nil,e,tp)
	if sg:GetCount()>0 then
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
function c35100316.thcon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE))
end
function c35100316.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function c35100316.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end