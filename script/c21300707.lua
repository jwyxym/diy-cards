--日冕曙龙
local s,id,o=GetID()
function s.initial_effect(c)
    --spsummon
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--xyzlv
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_XYZ_LEVEL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.xyzlv)
	e2:SetLabel(8)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetLabel(10)
	c:RegisterEffect(e3)
    --sps
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetCountLimit(1,id+o)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetTarget(s.stg)
    e4:SetOperation(s.sop)
    c:RegisterEffect(e4)
end
function s.filter(c,tp)
	return Duel.GetMZoneCount(tp,c)>0
end
function s.setfilter(c)
    return c:IsSetCard(0x680) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,c,tp)
	if chk==0 then return #g>1 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,2,2,aux.ExceptThisCard(e),tp)
	if Duel.Destroy(g,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
        local sg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil,e,tp)
        if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
            local tc=sg:Select(tp,1,1,nil)
            Duel.SSet(tp,tc)
        end
	end
end
--xyzlv
function s.xyzlv(e,c,rc)
	if rc:IsAttribute(ATTRIBUTE_FIRE) then
		return c:GetLevel()+0x10000*e:GetLabel()
	else
		return c:GetLevel()
	end
end
--spsummon
function s.spfilter(c,e,tp)
    return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end