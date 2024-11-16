--
function c19990030.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--spsummon1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19990030,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,19990030)
	e1:SetCondition(c19990030.spcon1)
	e1:SetTarget(c19990030.sptg1)
	e1:SetOperation(c19990030.spop1)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetDescription(aux.Stringid(19990030,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,19990030+100)
	e2:SetCondition(c19990030.thcon1)
	e2:SetTarget(c19990030.spstg)
	e2:SetOperation(c19990030.spsop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,19990030+100)
	e3:SetCondition(c19990030.thcon2)
	c:RegisterEffect(e3)
end
function c19990030.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb29)
end
function c19990030.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c19990030.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c19990030.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c19990030.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c19990030.cfilter1(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousControler(tp) and c:IsSetCard(0xb29)
end
function c19990030.thcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19990030.cfilter1,1,nil,tp)
end
function c19990030.cfilter2(c,tp)
	return c:IsFaceup() and c:IsPreviousControler(tp) and c:IsSetCard(0xb29,0xb30)
end
function c19990030.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19990030.cfilter2,1,nil,tp)
end
function c19990030.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c19990030.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end