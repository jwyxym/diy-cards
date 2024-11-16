--
function c19990028.initial_effect(c)
	c:SetSPSummonOnce(19990028)
	--link summon
	aux.AddLinkProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c19990028.atkval)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetCountLimit(1,19990028)
	e2:SetDescription(aux.Stringid(19990028,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetTarget(c19990028.spstg)
	e2:SetOperation(c19990028.spsop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
function c19990028.cfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE+LOCATION_FZONE)) and c:IsSetCard(0xb30) and c:IsType(TYPE_FIELD)
end
function c19990028.atkval(e,c)
	local g=Duel.GetMatchingGroup(c19990028.cfilter,c:GetControler(),LOCATION_REMOVED+LOCATION_GRAVE+LOCATION_FZONE,0,nil)
	return g:GetClassCount(Card.GetCode)*500
end
function c19990028.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c19990028.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
