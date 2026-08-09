--老牧师运转
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOEXTRA+CATEGORY_DECKDES+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.cftg)
	e1:SetOperation(s.cfop)
	c:RegisterEffect(e1)
end
function s.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroupCount(nil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,e:GetHandler())>0 end
end
function s.hfilter(c)
	return (c:IsFaceup() and c:IsLocation(LOCATION_REMOVED+LOCATION_ONFIELD+LOCATION_EXTRA)) or c:IsLocation(LOCATION_GRAVE)
end    
function s.tgfilter(c)
	return c:IsAbleToGrave() or c:IsLocation(LOCATION_REMOVED)
end    
function s.desfilter(c)
	return not c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end    
function s.txfilter(c)
	return not c:IsLocation(LOCATION_EXTRA) and c:IsType(TYPE_PENDULUM)
end            
function s.spfilter(c,e,tp,loc)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and c:IsLocation(loc)
    	and ((Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsLocation(LOCATION_EXTRA)) or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
end
function s.fspfilter(c,e,tp,loc)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN) and c:IsLocation(loc)
		and ((Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsLocation(LOCATION_EXTRA)) or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
end
function s.exfilter1(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
function s.exfilter2(c)
	return c:IsLocation(LOCATION_EXTRA) and (c:IsType(TYPE_LINK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
end
function s.gcheck(g,ft1,ft2,ft3,ect,ft)
	return g:GetCount()<=ft
		and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND)<=ft1
		and g:FilterCount(s.exfilter1,nil)<=ft2
		and g:FilterCount(s.exfilter2,nil)<=ft3
		and g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=ect
end
function s.cfop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,e:GetHandler())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local cg=g:Select(tp,1,g:GetCount(),nil)
    if cg:GetCount()<=0 then return end
    local fg=cg:Filter(Card.IsFacedown,nil)
    if fg:GetCount()>0 then
    	Duel.ConfirmCards(1-tp,fg)
    end
    local hg=cg:Filter(s.hfilter,nil)
    if hg:GetCount()>0 then
    	Duel.HintSelection(hg)
    end
    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
    local tg=cg:Filter(s.tgfilter,nil)
    local dg=cg:Filter(s.desfilter,nil)
    if (tg:GetCount()>0 or dg:GetCount()>0) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
    	Duel.BreakEffect()        
        local op1=aux.SelectFromOptions(tp,
			{tg:GetCount()>0,1103,1},
			{dg:GetCount()>0,aux.Stringid(id,3),2})
        if op1==1 then
        	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local stg=tg:Select(tp,1,tg:GetCount(),nil)
            if stg:GetCount()>0 then
            	Duel.HintSelection(stg)
            	Duel.SendtoGrave(stg,REASON_EFFECT)
                cg=cg-stg
            end
        elseif op1==2 then
        	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local sdg=dg:Select(tp,1,dg:GetCount(),nil)
            if sdg:GetCount()>0 then
            	Duel.HintSelection(sdg)
            	Duel.Destroy(sdg,REASON_EFFECT)
                cg=cg-sdg
            end
        end        
    end
    local rg=cg:Filter(aux.NecroValleyFilter(Card.IsAbleToRemove),nil)
    local frg=cg:Filter(aux.NecroValleyFilter(Card.IsAbleToRemove),nil,tp,POS_FACEDOWN)
    if (rg:GetCount()>0 or frg:GetCount()>0) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
    	Duel.BreakEffect()
        local op2=aux.SelectFromOptions(tp,
			{rg:GetCount()>0,aux.Stringid(id,5),1},
			{frg:GetCount()>0,aux.Stringid(id,6),2})
        if op2==1 then
        	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local srg=rg:Select(tp,1,rg:GetCount(),nil)
            if srg:GetCount()>0 then
            	Duel.HintSelection(srg)
            	Duel.Remove(srg,POS_FACEUP,REASON_EFFECT)
                cg=cg-srg
            end
        elseif op2==2 then
        	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local sfrg=frg:Select(tp,1,frg:GetCount(),nil)
            if sfrg:GetCount()>0 then
            	Duel.HintSelection(sfrg)
            	Duel.Remove(sfrg,POS_FACEDOWN,REASON_EFFECT)
                cg=cg-sfrg
            end
        end
    end
    local txg=cg:Filter(aux.NecroValleyFilter(s.txfilter),nil)
    if txg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,7)) then
    	Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,8))
        local stxg=txg:Select(tp,1,txg:GetCount(),nil)
        if stxg:GetCount()>0 then
        	Duel.HintSelection(stxg)
            Duel.SendtoExtraP(stxg,nil,REASON_EFFECT)
            cg=cg-stxg
        end
    end    
    local ect1=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	local ect2=aux.ExtraDeckSummonCountLimit and Duel.IsPlayerAffectedByEffect(tp,92345028)
    local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
	local ft3=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM+TYPE_LINK)
	local ft=Duel.GetUsableMZoneCount(tp)
    if ect1 and ect1>ft2 then ft2=ect1 end
	if ect1 and ect1>ft3 then ft3=ect1 end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		if ft1>0 then ft1=1 end
		if ft2>0 then ft2=1 end
		if ft3>0 then ft3=1 end
		ft=1
	end
	if ect2 and ect2<1 then
		if ft2>0 then ft2=0 end
		if ft3>0 then ft3=0 end
	end
	local loc=0
	if ft1>0 then loc=loc+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_HAND end
	if (not ect1 or ect1>0) and ft>0 and (ft2>0 or ft3>0) then loc=loc+LOCATION_EXTRA end
	if loc==0 then return end
    local sg=cg:Filter(aux.NecroValleyFilter(s.spfilter),nil,e,tp,loc)
    local fsg=cg:Filter(aux.NecroValleyFilter(s.fspfilter),nil,e,tp,loc)
    if (sg:GetCount()>0 or fsg:GetCount()>0) and Duel.SelectYesNo(tp,aux.Stringid(id,9)) then
    	Duel.BreakEffect()
        if not ect1 then ect1=ft end
       	local op3=aux.SelectFromOptions(tp,
			{sg:GetCount()>0,aux.Stringid(id,10),1},
			{fsg:GetCount()>0,aux.Stringid(id,11),2})
        if op3==1 then
        	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local ssg=sg:SelectSubGroup(tp,s.gcheck,false,1,sg:GetCount(),ft1,ft2,ft3,ect1,ft)
        	if ssg:GetCount()>0 then
            	Duel.SpecialSummon(ssg,0,tp,tp,false,false,POS_FACEUP)
            end
        elseif op3==2 then    
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sfsg=fsg:SelectSubGroup(tp,s.gcheck,false,1,fsg:GetCount(),ft1,ft2,ft3,ect1,ft)
        	if sfsg:GetCount()>0 then
            	Duel.SpecialSummon(sfsg,0,tp,tp,false,false,POS_FACEDOWN)
                Duel.ConfirmCards(1-tp,sfsg)
            end
        end
    end   
end