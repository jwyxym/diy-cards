--绝爱姦淫·瓦娜蕾格
local s,id,o=GetID()
function s.initial_effect(c)
	--融合召唤
	aux.AddFusionProcFunFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x5ca1),s.matfilter,2,127,true)
	c:EnableReviveLimit()
	--送去墓地	
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--特殊召唤
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES_SELF)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1,id+o*10000)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
    if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PAY_LPCOST)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)   
    end
end
function s.matfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsFusionAttribute(ATTRIBUTE_DARK)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp) 	
	Duel.RegisterFlagEffect(ep,id,0,0,0)    	
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetMaterialCount()
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end		
    local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetMaterialCount()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
    if g:GetCount()>0 then
    	Duel.HintSelection(g)
        if Duel.SendtoGrave(g,REASON_EFFECT)~=0 then 
        	local oc=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)        
            if oc>0 and c:IsRelateToEffect(e) and c:IsFaceup() and Duel.GetFlagEffect(tp,id)>=7 then
            	Duel.BreakEffect()
            	local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(2000)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
				c:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_UPDATE_DEFENSE)
				c:RegisterEffect(e2)
               	local e3=Effect.CreateEffect(c)
    			e3:SetDescription(aux.Stringid(id,3))
				e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_DIRECT_ATTACK)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				c:RegisterEffect(e3)            	
            end
        end
    end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x5ca1)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and c:IsSetCard(0x5ca1)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
    e:SetLabel(0)
    if e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) then
    	e:SetLabel(100)
        e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES_SELF+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
    end
end
function s.tdfilter(c)
	return c:IsRace(RACE_FIEND) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToDeck()
end    
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardHand(tp,nil,1,1,REASON_DISCARD+REASON_EFFECT,nil)~=0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
        if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0
        	and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
            and e:GetLabel()==100 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.BreakEffect()
            local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local tg=sg:Select(tp,1,sg:GetCount(),nil)
            if tg:GetCount()>0 then
            	Duel.HintSelection(tg)
                Duel.SendtoDeck(tg,nil,2,REASON_EFFECT)
            end
        end
	end
end