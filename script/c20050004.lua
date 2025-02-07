--梦想写作家
function c20050004.initial_effect(c)
	--change name
	aux.EnableChangeCode(c,19000032,LOCATION_REMOVED+LOCATION_GRAVE+LOCATION_DECK+LOCATION_HAND+LOCATION_MZONE)
	--to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20050004,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FLIP)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,20050004+100)
	e1:SetTarget(c20050004.thtg)
	e1:SetOperation(c20050004.thop)
	c:RegisterEffect(e1)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20050004,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetCountLimit(1,20050004)
	e3:SetCondition(c20050004.spscon)
	e3:SetTarget(c20050004.spstg)
	e3:SetOperation(c20050004.spsop)
	c:RegisterEffect(e3)
end
function c20050004.spscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT)
end
function c20050004.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_DEFENSE)~=0 and c:IsFacedown() then
		Duel.ConfirmCards(1-tp,c)
	end
end
function c20050004.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
	  Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c20050004.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c20050004.splimit(e,c)
	return not c:IsRace(RACE_ILLUSION)
end
function c20050004.thfilter(c)
	return c:IsCode(19000032) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE+LOCATION_DECK)) and c:IsAbleToHand()
end
function c20050004.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20050004.thfilter,tp,LOCATION_GRAVE+LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK+LOCATION_REMOVED)
end
function c20050004.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c20050004.thfilter,tp,LOCATION_GRAVE+LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

