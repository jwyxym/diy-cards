--
function c20010014.initial_effect(c)
	--change code
	aux.EnableChangeCode(c,20010010,LOCATION_DECK+LOCATION_HAND)
	--search
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(20010014,0))
	e0:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_SUMMON_SUCCESS)
	e0:SetTarget(c20010014.thtg)
	e0:SetOperation(c20010014.thop)
	c:RegisterEffect(e0)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20010014,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCountLimit(1,20010014)
	e1:SetCondition(c20010014.spcon)
	e1:SetTarget(c20010014.sptg)
	e1:SetOperation(c20010014.spop)
	c:RegisterEffect(e1)
	--disable summon
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,0)
	e5:SetTarget(c20010014.sumlimit)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e6)
	local e7=e5:Clone()
	e7:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e7)
end
function c20010014.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0xb33)
end
function c20010014.thfilter(c)
	return c:IsSetCard(0xb33) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c20010014.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20010014.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c20010014.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c20010014.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c20010014.spcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return c:IsReason(REASON_COST) and rc:IsSetCard(0xb33) and re:IsActivated()
end
function c20010014.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c20010014.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end