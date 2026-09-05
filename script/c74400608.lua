local s,id,o=GetID()
function s.initial_effect(c)

	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetValue(s.spval)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.lcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x74b) and c:IsType(TYPE_LINK)
end
function s.checkzone(tp)
	local zone=0
	local g=Duel.GetMatchingGroup(s.lcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		zone=bit.bor(zone,tc:GetLinkedZone(tp))
	end
	return bit.band(zone,0x1f)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=s.checkzone(tp)
	return zone~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
function s.spval(e,c)
	local tp=c:GetControler()
	local zone=s.checkzone(tp)
	return 0,zone
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return aux.exccon(e,tp,eg,ep,ev,re,r,rp) and not c:IsReason(REASON_RETURN)
end
function s.spfilter(c,e,tp,zone)
	return c:IsSetCard(0x74b) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=s.checkzone(tp)
	if chk==0 then return zone~=0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone=s.checkzone(tp)
	if zone==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
