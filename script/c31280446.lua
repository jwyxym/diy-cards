--猎装随从 泰拉大陆调查团
local s,id,o=GetID()
function s.initial_effect(c)
	--选择效果发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(s.eftg)
	e1:SetOperation(s.efop)
	c:RegisterEffect(e1)
end
function s.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9ca1) and c:GetSequence()<5
end    
function s.setfilter(c)
	return c:IsSetCard(0x9ca1) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.thfilter(c)
	return c:IsSetCard(0x9ca1) and c:IsAbleToHand() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.getzone(tp)
	local zone=0
	local g=Duel.GetMatchingGroup(s.confilter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
    	local seq=tc:GetSequence()
		if seq>0 then zone=zone|(1<<(seq-1)) end
		if seq<4 then zone=zone|(1<<(seq+1)) end
	end
	return zone
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    local zone=s.getzone(tp)
	local b1=c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
    	and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
    	and (Duel.GetFlagEffect(tp,id)==0 or not e:IsCostChecked())
    local b2=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)    	
    	and (Duel.GetFlagEffect(tp,id+o)==0 or not e:IsCostChecked())
        and c:IsAbleToGrave()
    local b3=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
    	and (Duel.GetFlagEffect(tp,31280444)==0 or not e:IsCostChecked())
        and c:IsAbleToDeck()
	if chk==0 then return (b1 or b2 or b3) end
    local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},
		{b2,aux.Stringid(id,2),2},
        {b3,aux.Stringid(id,3),3})
	e:SetLabel(op)
    if op==1 then
    	if e:IsCostChecked() then
    		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
            Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
        end
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    elseif op==2 then
    	if e:IsCostChecked() then
    		e:SetCategory(CATEGORY_SSET+CATEGORY_TOGRAVE)
            Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
        end
        Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)  
    elseif op==3 then
    	if e:IsCostChecked() then
    		e:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
        	Duel.RegisterFlagEffect(tp,31280444,RESET_PHASE+PHASE_END,0,1)
        end
        Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0) 
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)   
    end
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
    local c=e:GetHandler()
	if op==1 then
    	local zone=s.getzone(tp)
        if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0 then return end
    	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)~=0 then
        	local dg=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
            if dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
            	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
                local sg=dg:Select(tp,1,1,nil)
                Duel.HintSelection(sg)
                Duel.Destroy(sg,REASON_EFFECT)
            end
		end
	elseif op==2 then
    	if c:IsRelateToEffect(e) then
        	Duel.SendtoGrave(c,REASON_EFFECT)
        end    
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then 
            Duel.SSet(tp,g) 
        end
    elseif op==3 then
    	if c:IsRelateToEffect(e) then
        	Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
        end   
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		if g:GetCount()>0 then 
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
	end
end