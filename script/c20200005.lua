--疯狂梦境的爱丽丝
function c20200005.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c20200005.condition)
	e1:SetCountLimit(1,20200005+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c20200005.target)
	e1:SetOperation(c20200005.activate)
	c:RegisterEffect(e1)
end
function c20200005.spfilter(c)
	return c:IsCode(20200003) and c:IsFaceup()
end
function c20200005.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c20200005.spfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c20200005.filter(c,e,tp)
	return c:IsSetCard(0xb31) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c20200005.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c20200005.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c20200005.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c20200005.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

