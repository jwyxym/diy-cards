--绝爱的飞翔
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
end
function s.tdfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToDeck() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE+LOCATION_HAND))
end    
function s.fselect(g)
	return g:IsExists(Card.IsSetCard,1,nil,0x5ca1)
end    
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if chk==0 then return g:CheckSubGroup(s.fselect,1,7) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)    
end
function s.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_FIEND) and c:IsLevelBelow(6) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:SelectSubGroup(tp,s.fselect,false,1,7)
	if not sg then return end
    local hg=sg:Filter(Card.IsLocation,nil,LOCATION_HAND)
    local grg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE+LOCATION_REMOVED)
    if hg:GetCount()>0 then
    	Duel.ConfirmCards(1-tp,hg)
    end
    if grg:GetCount()>0 then
    	Duel.HintSelection(grg)
    end    
    if Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)~=0 then
    	local oc=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
    	if oc<=0 then return end
    	local chkf=tp
		local mg1=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK):Filter(s.filter1,nil,e)
        local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2=nil
		local sg2=nil
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		if (sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0)) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.ShuffleHand(tp)
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				Duel.BreakEffect()
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			else
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
        	tc:CompleteProcedure()
            if tc:IsSetCard(0x5ca1) then
            	Duel.BreakEffect()
            	local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetCategory(CATEGORY_DEFCHANGE)
				e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_ATTACK_ANNOUNCE)
				e1:SetOperation(s.defop)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
                tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
            end
        end
    end
end
function s.defilter(c)
	return c:IsFaceup() and aux.nzdef(c)
end
function s.defop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLP(tp)<400 or Duel.GetLP(1-tp)<400 then return end
    local g=Duel.GetMatchingGroup(s.defilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    if g:GetCount()<=0 then return end
    Duel.Hint(HINT_CARD,0,id)
	if Duel.PayLPCost(tp,400)~=0 and Duel.PayLPCost(1-tp,400)~=0 then    	
    	for i=1,2 do
    		if i>1 then Duel.BreakEffect() end
            local dg=Group.CreateGroup()
            for tc in aux.Next(g) do
                local pdef=tc:GetDefense()
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_DEFENSE)
				e1:SetValue(-1000)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
                Duel.AdjustAll()
				if pdef~=0 and tc:IsDefense(0) then 
                	dg:AddCard(tc) 
                end
			end
            if dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            	Duel.BreakEffect()
            	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
                local sg=dg:Select(tp,1,dg:GetCount(),nil)
                if sg:GetCount()>0 then
                	Duel.HintSelection(sg)
                    Duel.Destroy(sg,REASON_EFFECT)                    
                end
            end
    	end
    end
end