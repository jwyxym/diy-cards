--ISM 亲和
local s,id,o=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--超量召唤
	aux.AddXyzProcedureLevelFree(c,s.mfilter,s.xyzcheck,2,99)
	c:EnableReviveLimit()
	--除外    
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2)
    s.remove_effect=e2
	--对象抗性    
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	--特殊召唤    
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)    
end
function s.mfilter(c,xyzc)
	return c:IsSetCard(0x682) and c:GetRank()>0
end
function s.xyzcheck(g)
	return g:GetClassCount(Card.GetRank)==1
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_ONFIELD+LOCATION_GRAVE)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
    if g:GetCount()<=0 then return end
    local fg=g:Filter(Card.IsOnField,nil)
    local rg=Group.CreateGroup()
    local res=false
	if fg:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FIELD_FIRST)
		local sg=fg:CancelableSelect(tp,1,1,nil)
		if sg then
			rg:Merge(sg)
            res=true			
		end    					
	end   
    if not res then
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    	rg=g:Select(tp,1,1,nil)
    end    
    Duel.HintSelection(rg)
    Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0x682)
    	and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    local st=c:GetOverlayCount()
    local con=st>=2 and Duel.IsPlayerAffectedByEffect(tp,59822133)
	if chk==0 then
		if e:GetLabel()==100 then
			return st>0 and not con and Duel.GetLocationCount(tp,LOCATION_MZONE)>=st
            	and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,st,nil,e,tp)
		else return false end
	end
    local og=c:GetOverlayGroup()
    local ct=Duel.SendtoGrave(og,REASON_COST)
    e:SetLabel(ct)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.xyzfilter(c)
	return c:IsRace(RACE_ILLUSION) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsXyzSummonable(nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
    if ct>=2 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if Duel.GetMatchingGroupCount(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)<ct
    	or ct<=0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<ct then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,ct,ct,nil,e,tp)
    if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then 
    	Duel.AdjustAll()
    	if Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil)
    		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        	Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil)
			Duel.XyzSummon(tp,sg:GetFirst(),nil)  
        end          
    end   
end