--
function c19990017.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--Special Summon1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19990017,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_REMOVED+LOCATION_HAND)
	e1:SetCountLimit(1,19990017)
	e1:SetCost(c19990017.tccost)
	e1:SetTarget(c19990017.spstg)
	e1:SetOperation(c19990017.spsop)
	c:RegisterEffect(e1)
	--Special Summon2
	local e2=Effect.CreateEffect(c)
	e2:SetCountLimit(1,19990017)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,21187632)
	e2:SetCondition(c19990017.spscon)
	e2:SetTarget(c19990017.spstg)
	e2:SetOperation(c19990017.spsop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
function c19990017.cfilter(c,tp)
	return c:IsSetCard(0xb29)
end
function c19990017.tccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,c19990017.cfilter,1,REASON_COST,true,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroupEx(tp,c19990017.cfilter,1,1,REASON_COST,true,c,tp)
	Duel.Release(g,REASON_COST)
end
function c19990017.spscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_RELEASE)
end
function c19990017.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c19990017.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
