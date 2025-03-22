--遨游星海的梦蛇
function c19000055.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	c:EnableReviveLimit()
	--change name
	aux.EnableChangeCode(c,19000032,LOCATION_HAND+LOCATION_EXTRA)
	--reduce tribute
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(19000055,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetTargetRange(LOCATION_HAND,0)
	e0:SetCode(EFFECT_SUMMON_PROC)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCondition(c19000055.ntcon)
	e0:SetTarget(c19000055.nttg)
	c:RegisterEffect(e0)
	--Pzone spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19000055,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,19000055)
	e1:SetTarget(c19000055.sptg)
	e1:SetOperation(c19000055.spop)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19000055,2))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,19000055+100)
	e2:SetTarget(c19000055.thtg)
	e2:SetOperation(c19000055.thop)
	c:RegisterEffect(e2)
	--Hand spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19000055,3))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetCountLimit(1,19000055+200)
	e3:SetCondition(c19000055.spscon)
	e3:SetTarget(c19000055.spstg)
	e3:SetOperation(c19000055.spsop)
	c:RegisterEffect(e3)
end
function c19000055.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function c19000055.nttg(e,c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_ILLUSION)
end
function c19000055.rfilter(c,tp,ec)
	return c:IsRace(RACE_ILLUSION) and c:IsReleasableByEffect()
		and c:IsLevel(6) and c:IsType(TYPE_MONSTER)
		and Duel.GetLocationCountFromEx(tp,tp,c,ec)>0
end
function c19000055.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c19000055.rfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,c,tp,c)
	if chk==0 then return #g>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true) end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c19000055.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,c19000055.rfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,aux.ExceptThisCard(e),tp,c)
	if Duel.Release(g,REASON_EFFECT) and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,SUMMON_TYPE_RITUAL,tp,tp,true,true,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c19000055.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c19000055.splimit(e,c)
	return not c:IsRace(RACE_ILLUSION)
end
function c19000055.thfilter(c)
	return c:IsCode(20050015,20050016) and c:IsAbleToHand()
end
function c19000055.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19000055.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c19000055.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c19000055.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c19000055.spscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT)
end
function c19000055.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c19000055.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,SUMMON_TYPE_RITUAL,tp,tp,true,true,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end