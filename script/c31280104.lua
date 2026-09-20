--羁绊的共振
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280102,31280120)
	--发动
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_RECOVER+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)	
	e1:SetTarget(s.eftg)
	e1:SetOperation(s.efop)
	c:RegisterEffect(e1)
end
function s.tgfilter(c)
	return c:IsAbleToGrave() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,c)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1600)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and aux.IsCodeListed(c,31280102)
end
function s.fselect(g,tp,ct)
	return Duel.GetMZoneCount(tp,g)>=ct
end
function s.thfilter(c)
	return aux.IsCodeListed(c,31280120) and c:IsAbleToHand()
end
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e) and c:IsLocation(LOCATION_MZONE) and c:IsCanBeFusionMaterial()
end
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,c)
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
    local ct=sg:GetCount()
    if ct>3 then ct=3 end
    if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
    local b=tg:CheckSubGroup(s.fselect,1,ct,tp,ct) and sg:GetCount()>0
    local op=aux.SelectFromOptions(tp,
		{b,aux.Stringid(id,1),1},
		{true,aux.Stringid(id,2),2})
    if op==1 then        
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    	local fg=tg:SelectSubGroup(tp,s.fselect,false,1,ct,tp,ct)
    	if fg and fg:GetCount()>0 and Duel.SendtoGrave(fg,REASON_EFFECT)~=0 then
    		local st=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
    		if st<=0 then return end
        	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        	local ng=sg:Select(tp,st,st,nil)
        	if ng:GetCount()<st or Duel.GetLocationCount(tp,LOCATION_MZONE)<st then return end
        	Duel.SpecialSummon(ng,0,tp,tp,false,false,POS_FACEUP)    
            local og=Duel.GetOperatedGroup()
			Duel.AdjustAll()
            local chkf=tp
			local mg1=og:Filter(s.filter1,nil,e)
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
			if (sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0)) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            	Duel.BreakEffect()
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
			end
        end
    elseif op==2 then
    	if Duel.Recover(tp,1600,REASON_EFFECT)~=0 
        	and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
        	Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
			if g:GetCount()>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
        end
    end
end