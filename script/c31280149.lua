--毒牙公主·梅杜莎
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280146,31280148)
	--融合召唤	
	aux.AddFusionProcCodeFun(c,31280146,aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),1,true,true)
    c:EnableReviveLimit()
	--抗性    
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	--特殊召唤
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
    e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--选择效果发动    
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o*10000)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCondition(s.efcon)
    e4:SetCost(s.efcost)
	e4:SetTarget(s.eftg)
	e4:SetOperation(s.efop)
	c:RegisterEffect(e4)
end
function s.confilter(c)
	return c:IsFaceup() and c:IsCode(31280146)
end
function s.indcon(e)
	return Duel.IsExistingMatchingCard(s.confilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.spfilter(c,e,tp,mg)
	return c:IsType(TYPE_FUSION) and c:GetOriginalCode()==31280148 and c:CheckFusionMaterial()
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
function s.fselect(g,e,tp)
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(31280146)
end    
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return g:CheckSubGroup(s.fselect,2,2,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:SelectSubGroup(tp,s.fselect,false,2,2,e,tp)
    Duel.SendtoGrave(sg,REASON_COST)	
end    
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
	if tc then
		tc:SetMaterial(nil)
		if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)~=0 then
        	local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,4))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.efilter)
			e1:SetOwnerPlayer(tp)
			tc:RegisterEffect(e1,true)			            
        end
        tc:CompleteProcedure()
	end
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.efcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.tgfilter(c,tp)
	return c:IsType(TYPE_EFFECT) and c:IsFaceup() and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,tp)
end
function s.eqfilter(c,tp)
	return c:IsCode(31280146) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.costfilter(c)
	return c:IsCode(31280146) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
    local b2=e:GetLabel()==100 and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil)
    	and Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	if chk==0 then return (b1 or b2) end
    local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),1},
		{b2,aux.Stringid(id,3),2})
	e:SetLabel(op)
    if op==1 then
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
        Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
    elseif op==2 then
    	e:SetCategory(CATEGORY_DESTROY)
    	local ct=Duel.GetTargetCount(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
        if ct>2 then ct=2 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,ct,nil)
        Duel.HintSelection(g)
		local cg=Duel.SendtoDeck(g,nil,2,REASON_COST)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,cg,cg,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
    end
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
    	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		local c=e:GetHandler()
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,tp)
			local ec=g:GetFirst()
			if not ec or not Duel.Equip(tp,ec,tc) then return end
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			e1:SetLabelObject(tc)
			ec:RegisterEffect(e1)
        end    
    elseif op==2 then
    	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
		if tg:GetCount()>0 then
			Duel.Destroy(tg,REASON_EFFECT)
		end
    end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end