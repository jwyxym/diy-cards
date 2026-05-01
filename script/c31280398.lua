--绝爱姦淫·瓦娜蕾格
local s,id,o=GetID()
function s.initial_effect(c)	
	--融合召唤
	aux.AddFusionProcFunFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x5ca1),s.matfilter,2,127,true)
	c:EnableReviveLimit()
	--检测    
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCondition(s.repcon)
	e0:SetOperation(s.repop)
	c:RegisterEffect(e0)
	--送去墓地
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
    e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--直接攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	--选择效果发动
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCountLimit(1,id+o*10000)
	e3:SetCondition(s.efcon)
    e3:SetCost(s.efcost)
	e3:SetTarget(s.eftg)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3)
    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
function s.counterfilter(c)
	return c:IsRace(RACE_FIEND)
end
function s.matfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsFusionAttribute(ATTRIBUTE_DARK)
end
function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOGRAVE-RESET_LEAVE-RESET_TOFIELD,0,1)  
end    
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetMaterialCount()
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,ct,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetMaterialCount()
    if ct<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
    if g:GetCount()>0 then
        Duel.HintSelection(g)
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end
function s.efcon(e,tp,eg,ep,ev,re,r,rp)	
	return re and re:GetHandler():IsSetCard(0x5ca1)
end
function s.efcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
	return not c:IsRace(RACE_FIEND)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x5ca1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.setfilter(c)
	return c:IsSetCard(0x5ca1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
    local b2=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return (b1 or b2) end
    local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),1},
		{b2,aux.Stringid(id,3),2})
	e:SetLabel(op)
    local c=e:GetHandler()
	if op==1 then
    	if c:GetFlagEffect(id)>0 then
    		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
        else
        	e:SetCategory(CATEGORY_SPECIAL_SUMMON)
        end    
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
    elseif op==2 then    
    	if c:GetFlagEffect(id)>0 then
    		e:SetCategory(CATEGORY_SSET+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION+CATEGORY_SPECIAL_SUMMON)
        else    
    		e:SetCategory(CATEGORY_SSET)    
       	end     	
    end        
end
function s.txfilter(c)
	return c:IsCode(id) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToExtra()
end    
function s.exfilter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
    local res=0
    if op==1 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			res=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)			
		end        
    elseif op==2 then    
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then 
        	res=Duel.SSet(tp,g) 
        end
    end
    if res~=0 and c:GetFlagEffect(id)>0 then
    	Duel.BreakEffect()
    	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.txfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
        if tg:GetCount()==0 then return end
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=tg:Select(tp,1,tg:GetCount(),nil)
    	Duel.HintSelection(sg)
        if Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)~=0 then
        	local oc=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
            if oc>0 and Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
            	and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local fg=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
				if fg:GetCount()>0 then
					Duel.SpecialSummon(fg,0,tp,tp,false,false,POS_FACEUP)
				end
            end   
        end
    end
    c:ResetFlagEffect(id)
end