--疯狂国度的梦幻之旅
function c19991010.initial_effect(c)
	--change code
	aux.EnableChangeCode(c,19991003,LOCATION_GRAVE)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,19991010+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c19991010.target)
	e1:SetOperation(c19991010.activate)
	c:RegisterEffect(e1)
end
function c19991010.filter(c,e,tp)
	return c:IsSetCard(0xb31) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function c19991010.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c19991010.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function c19991010.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c19991010.filter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end