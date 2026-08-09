--
function c19993032.initial_effect(c)
	c:SetSPSummonOnce(19993032)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--change attribute to DARK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1:SetRange(LOCATION_ONFIELD)
	e1:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0)
	e1:SetTarget(c19993032.attfilter)
	e1:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e1)
	--tribute opponent's monster instead (EFFECT_EXTRA_RELEASE_NONSUM)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_RELEASE_NONSUM)
	e2:SetRange(LOCATION_ONFIELD)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(aux.TRUE)
	e2:SetValue(c19993032.relval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(19993032)
	c:RegisterEffect(e3)
	--Effect monster on field
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_ADD_TYPE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e4)
	--special summon itself from GY
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(19993032,0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,19993032)
	e5:SetTarget(c19993032.sptg)
	e5:SetOperation(c19993032.spop)
	c:RegisterEffect(e5)
end
function c19993032.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c19993032.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		c:AddMonsterAttribute(TYPE_MONSTER)
		Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
	end
end
function c19993032.attfilter(e,c)
	return c:IsSetCard(0xb35) and c:IsFaceupEx()
end
function c19993032.relval(e,re,r,rp)
	return re and re:IsActivated() and bit.band(r,REASON_COST)~=0
		and re:GetHandler():IsSetCard(0xb35)
end
