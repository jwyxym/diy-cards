--
function c19990031.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--non tuner
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_NONTUNER)
	e0:SetRange(LOCATION_MZONE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetValue(c19990031.tnval)
	c:RegisterEffect(e0)
	--spsummon1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19990031,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_REMOVED+LOCATION_GRAVE)
	e1:SetCountLimit(1,19990031)
	e1:SetCondition(c19990031.spcon1)
	e1:SetTarget(c19990031.sptg1)
	e1:SetOperation(c19990031.spop1)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetDescription(aux.Stringid(19990031,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,19990031+100)
	e2:SetCondition(c19990031.thcon1)
	e2:SetTarget(c19990031.spstg)
	e2:SetOperation(c19990031.spsop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,19990031+100)
	e3:SetCondition(c19990031.thcon2)
	c:RegisterEffect(e3)
end
function c19990031.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb30)
end
function c19990031.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c19990031.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c19990031.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c19990031.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c19990031.cfilter1(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousControler(tp) and c:IsSetCard(0xb29)
end
function c19990031.thcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19990031.cfilter1,1,nil,tp)
end
function c19990031.cfilter2(c,tp)
	return c:IsFaceup() and c:IsPreviousControler(tp) and c:IsSetCard(0xb29,0xb30)
end
function c19990031.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19990031.cfilter2,1,nil,tp)
end
function c19990031.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c19990031.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c19990031.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end