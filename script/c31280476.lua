--轮回追猎者·科尔努诺丝
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280102)
	--融合召唤
	aux.AddFusionProcFun2(c,s.matfilter,aux.FilterBoolFunction(Card.IsFusionType,TYPE_EFFECT),false)
	c:EnableReviveLimit()
    --特召限制    
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.fuslimit)
	c:RegisterEffect(e0)
	--解放    
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rlcon1)
	e1:SetTarget(s.rltg)
	e1:SetOperation(s.rlop)
	c:RegisterEffect(e1)
    local e2=e1:Clone()
	e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCondition(s.rlcon2)
	c:RegisterEffect(e2)
	--回到卡组    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*10000)
	e3:SetCondition(s.tdcon)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
function s.matfilter(c)
	return aux.IsCodeListed(c,31280102) and c:IsType(TYPE_MONSTER)
end
function s.fuslimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end    
function s.rlcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
function s.rlcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
function s.rlfilter(c)
	return aux.IsCodeListed(c,31280102) and c:IsType(TYPE_MONSTER) and c:IsReleasableByEffect()
end
function s.rltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rlfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.rlop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.rlfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Release(g,REASON_EFFECT)
	end
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.tdfilter(c,e)
	return c:IsAbleToDeck() and c:IsCanBeEffectTarget(e) and c:IsType(TYPE_MONSTER)
end    
function s.selectfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_ZOMBIE)
end
function s.fselect(g)
	return g:IsExists(s.selectfilter,1,nil)
end    
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.tdfilter(chkc,e) end
	if chk==0 then return tg:GetCount()>0 and tg:CheckSubGroup(s.fselect,1,3) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=tg:SelectSubGroup(tp,s.fselect,false,1,3)
    Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,sg:GetCount(),0,0)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,2,REASON_EFFECT)~=0 then
    	local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
        if og:GetCount()<=0 then return end
        local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
        local sg1=og:Filter(s.filter2,nil,e,tp,mg1,nil,chkf)
        local mg2=nil
		local sg2=nil
		local ce=Duel.GetChainMaterial(tp)
        if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			sg2=og:Filter(s.filter2,nil,e,tp,mg2,mf,chkf)
        end
		if (sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0)) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
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
end