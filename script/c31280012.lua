--纪律的继任
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_GRAVE_SPSUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--盖放    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
    if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.confilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_FUSION) and c:IsSetCard(0x9caa)
end    
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetOwner()
	local g=eg:Filter(s.confilter,nil,p)
	for tc in aux.Next(g) do
		Duel.RegisterFlagEffect(p,id,0,0,0)
	end
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsSetCard(0x9caa) or (c:IsRace(RACE_MACHINE) and c:IsType(TYPE_FUSION)))
    	and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED)) and ((c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
        or (c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_DECK) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsPlayerCanSpecialSummonMonster(tp,31280056,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_MACHINE,ATTRIBUTE_LIGHT)
    local b2=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,1,nil,e,tp)
	if chk==0 then return (b1 or b2) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>=7 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
    	local ft=math.min(2,Duel.GetLocationCount(tp,LOCATION_MZONE))
		if ft==0 then return end
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,1,ft,nil,e,tp)
		if g:GetCount()>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end    
    else
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local ct=2
		if ft>0 and ct>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,31280056,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_MACHINE,ATTRIBUTE_LIGHT) then
			local count=math.min(ft,ct)
			if Duel.IsPlayerAffectedByEffect(tp,59822133) then count=1 end
			if count>1 then
				local num={}
				local i=1
				while i<=count do
					num[i]=i
					i=i+1
				end
				Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
				count=Duel.AnnounceNumber(tp,table.unpack(num))
			end
			local lv=count
			repeat
				local token=Duel.CreateToken(tp,31280056)
				Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
				count=count-1
			until count==0
			Duel.SpecialSummonComplete()
        end    
    end    
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SSet(tp,c)
	end
end