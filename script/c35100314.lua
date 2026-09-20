--白象的亲卫 莽应龙
function c35100314.initial_effect(c)
	--spSummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35100314,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,35100314)
	e1:SetCost(c35100314.spcost1)
	e1:SetTarget(c35100314.sptg1)
	e1:SetOperation(c35100314.spop1)
	c:RegisterEffect(e1)
    --search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35100314,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,35100315)
	e2:SetTarget(c35100314.thtg1)
	e2:SetOperation(c35100314.thop1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
    local e4=e2:Clone()
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(c35100314.thcon)
	c:RegisterEffect(e4)
	--bgm
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetOperation(c35100314.sumsuc)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e8)
end
function c35100314.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_MUSIC,0,aux.Stringid(35100314,3))
end 
function c35100314.costfilter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAbleToRemoveAsCost()
end
function c35100314.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c35100314.costfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c35100314.costfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c35100314.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c35100314.spop1(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
function c35100314.thfilter(c)
	return c:IsSetCard(0x3a92) and c:IsAbleToHand()
end
function c35100314.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and not re:GetHandler():IsCode(35100314)
end
function c35100314.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c35100314.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c35100314.thop1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c35100314.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c35100314.con)
	e1:SetValue(1)
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
	end
	Duel.RegisterEffect(e1,tp)
end
function c35100314.con(e)
	local ph=Duel.GetCurrentPhase()
	return not (ph==PHASE_MAIN1 or ph==PHASE_MAIN2 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE))
end