--Welcome To The Saviors' Game
local s,id,o=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e0)
	--改变卡名并当作调整
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.chtg)
	e1:SetValue(16820686)
	c:RegisterEffect(e1)
    local e2=e1:Clone()
	e2:SetCode(EFFECT_ADD_TYPE)
    e2:SetValue(TYPE_TUNER)
	c:RegisterEffect(e2)
	--盖放    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_MOVE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.setcon)
    e3:SetCost(s.setcost)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
function s.chtg(e,c)
	local seq=c:GetSequence()
	return c:IsType(TYPE_EFFECT) and (c:GetOriginalCode()~=16820686 or not c:IsType(TYPE_TUNER))
    	and seq<5 and math.abs(e:GetHandler():GetSequence()-seq)<=1 
end
function s.cfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsPreviousLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=c:GetControler())
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.costfilter(c,e,tp)
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xdf99) and c:IsAbleToGraveAsCost() 
    	and ((g:FilterCount(s.spfilter,nil,e,tp)>0 and Duel.GetMZoneCount(tp,c)>0) or (g:FilterCount(s.stfilter,nil)>0 and Duel.GetSZoneCount(tp,c)>0))
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler(),e,tp)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.setfilter(c,e,tp)
	return ((c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)) or (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(true)))
    	and c:IsSetCard(0xdf99) and not c:IsCode(id)  
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end    
function s.stfilter(c)
	return c:IsSSetable()
end    
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil,e,tp)
    if g:GetCount()==0 then return end
    local sg1=g:Filter(s.spfilter,nil,e,tp)
    local sg2=g:Filter(s.stfilter,nil)
    if sg1:GetCount()>0 and sg2:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		local sg=g:Select(tp,1,1,nil)
        local tc=sg:GetFirst()
        if tc:IsType(TYPE_MONSTER) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 and tc:IsFacedown() then
			Duel.ConfirmCards(1-tp,tc)
        else
        	Duel.SSet(tp,tc)            	
        end
    elseif sg1:GetCount()>0 and sg2:GetCount()==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=sg1:Select(tp,1,1,nil)
        local tc=sg:GetFirst()
        if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 and tc:IsFacedown() then
			Duel.ConfirmCards(1-tp,tc)
        end    
    elseif sg2:GetCount()>0 and (sg1:GetCount()==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0) then
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=sg2:Select(tp,1,1,nil)
        local tc=sg:GetFirst()
		Duel.SSet(tp,tc)
    end
end