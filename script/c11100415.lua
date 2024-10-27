--亡龙骨  超界邪龙
local s,id,o=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,11100400)
    --change name
	aux.EnableChangeCode(c,11100400,LOCATION_MZONE+LOCATION_GRAVE)
	--link summon
	aux.AddLinkProcedure(c,s.mfilter,2,3,s.lcheck)
	c:EnableReviveLimit()
    --spsummon
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.mfilter(c)
	return c:IsLinkRace(RACE_DRAGON) and c:IsLinkAttribute(ATTRIBUTE_EARTH)
end
function s.lcheck(g,lc)
	return g:IsExists(Card.IsCode,1,nil,11100400)
end
function s.spfilter(c,e,tp)
	local zone=e:GetHandler():GetLinkedZone(tp)
	return c:IsCode(11100400) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk) 
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end 
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0 then return end
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
    Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
end