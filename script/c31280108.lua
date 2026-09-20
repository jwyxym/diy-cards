--死灵的诱惑
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280102)
	--发动    
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)	
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--融合召唤
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.fsptg)
	e2:SetOperation(s.fspop)
	c:RegisterEffect(e2)    
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(5)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.confilter(c)
	return c:IsFaceup() and aux.IsCodeListed(c,31280102)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
    	local b1=Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
        local b2=Duel.GetFieldGroup(tp,LOCATION_GRAVE,0):GetClassCount(Card.GetCode)>=8
        if (b1 or b2) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and aux.NecroValleyFilter()(tc) 
        	and not (tc:IsLocation(LOCATION_HAND+LOCATION_DECK) or (tc:IsLocation(LOCATION_REMOVED) and tc:IsFacedown()))
            and ((not tc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) or (tc:IsLocation(LOCATION_EXTRA) 
            and tc:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0)) and tc:IsType(TYPE_MONSTER)
        	and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.BreakEffect()
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end
function s.tgfilter(c,e,tp)	
	return c:IsFaceup() and c:IsCanBeFusionMaterial()
    	and Duel.IsExistingMatchingCard(s.fufilter,tp,LOCATION_MZONE,0,1,nil,e,tp,c)    	
end
function s.fufilter(c,e,tp,fc)
	local mg=Group.FromCards(c,fc)
	return c:IsCanBeFusionMaterial() and Duel.IsExistingMatchingCard(s.fspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
end
function s.fspfilter(c,e,tp,mg)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_ZOMBIE)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(mg)
end
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tgfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end	
function s.fselect(g,sc,mc)
	return sc:CheckFusionMaterial(g) and g:IsContains(mc)
end
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or tc:IsFacedown()
    	or not tc:IsCanBeFusionMaterial() then return end
    local mg=Duel.GetMatchingGroup(s.fufilter,tp,LOCATION_MZONE,0,nil,e,tp,tc)
    if mg:GetCount()<=0 then return end
    mg:AddCard(tc)
    local sg=Duel.GetMatchingGroup(s.fspfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg)
    if sg:GetCount()<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=sg:Select(tp,1,1,nil):GetFirst()
    if not sc then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
    local fg=mg:SelectSubGroup(tp,s.fselect,false,2,2,sc,tc)
    if fg and fg:GetCount()>0 then
    	sc:SetMaterial(fg)
    	Duel.SendtoGrave(fg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
        Duel.BreakEffect()
		Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        sc:CompleteProcedure()
    end   
end