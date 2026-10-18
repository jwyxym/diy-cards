--霜冻之影 涅瑞伊斯
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,21301247)
	--同调召唤
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	--特殊召唤	
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	e0:SetLabelObject(e1)
	c:RegisterEffect(e0)
	--同调召唤    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e2:SetCost(s.cost)
	e2:SetTarget(s.syntg)
	e2:SetOperation(s.synop)
	c:RegisterEffect(e2)        
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or (c:IsType(TYPE_SYNCHRO) and c:IsFaceup())
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO)
end
function s.mfilter(c)
	return not aux.IsCodeListed(c,21301247)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:GetCount()>0 and not g:IsExists(s.mfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()==1
end
function s.spfilter(c,e,tp,sync)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:GetReasonCard()==sync
		and bit.band(c:GetReason(),0x80008)==0x80008 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    local mg=c:GetMaterial()
    local ct=mg:GetCount()
	if chk==0 then return ct>0 and mg:FilterCount(s.spfilter,nil,e,tp,c)==ct
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	Duel.SetTargetCard(mg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,mg,ct,0,0)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.lvfilter(c,lv)
	return c:IsFaceup() and not c:IsLevel(lv)
end
function s.tgfilter(c,tp,g)
	return c:IsFaceup() and c:IsLevelAbove(1) and g:IsContains(c)
    	and Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,c,c:GetLevel())    	
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	local sg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()<Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):GetCount() then return end    
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<sg:GetCount() then return end
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)==sg:GetCount()
    	and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp,sg)
    	and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
    	Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,sg):GetFirst()
        if not tc then return end
        Duel.HintSelection(Group.FromCards(tc))
        local vg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
        for vc in aux.Next(vg) do
        	local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(tc:GetLevel())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			vc:RegisterEffect(e1)
        end
    end
end
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetSynchroMaterial(tp)
	if chk==0 then return g:GetCount()>0 and Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,g) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetSynchroMaterial(tp)
	if g:GetCount()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,1,nil,nil,g):GetFirst()
	if sc then
    	Duel.SynchroSummon(tp,sc,nil,g)
    end
end