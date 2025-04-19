local cm,m=GetID()
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end

function cm.cfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x614) or c:IsSetCard(0x615)) and c:IsType(TYPE_MONSTER)
end

function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,cm.cfilter,1,nil) end
	local g=Duel.SelectReleaseGroup(tp,cm.cfilter,1,1,nil)
	Duel.Release(g,REASON_COST)
end

function cm.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_SPELLCASTER) and c:IsLevelBelow(7)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function cm.fusfilter(c,e,tp,m,f,gc,chkf)
	return (c:IsRace(RACE_FAIRY) or c:IsRace(RACE_FIEND)) and c:IsType(TYPE_FUSION)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial(m,gc,chkf)
end

function cm.fmfilter(c,e,tp,sp)
	return c:IsCanBeFusionMaterial() and (c:IsLocation(LOCATION_GRAVE+LOCATION_MZONE+LOCATION_EXTRA) or c:IsLocation(LOCATION_DECK))
		and (not e or not c:IsImmuneToEffect(e))
		and (not sp or aux.SpElimFilter(c,true))
end

function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function cm.fusiontg(e,tp,tc)
		local chkf=tp
		local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(cm.filter0),tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_EXTRA,0,nil,e)
		local res=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(cm.filter2),tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf,tc)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(cm.filter2),tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf,tc)
			end
		end  
   return true 
end
function cm.filter0(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e) and (c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
end
function cm.filter1(c,e,tp,m,f,chkf,tc)
	if not (c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	local res=c:CheckFusionMaterial(m,nil,chkf)
	return res
end
function cm.filter2(c,e,tp,m,f,chkf,tc)
	return (c:IsRace(RACE_FAIRY) or c:IsRace(RACE_FIEND)) and c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,tc,chkf)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local gc=g:GetFirst()
	if gc and Duel.SpecialSummon(gc,0,tp,tp,false,false,POS_FACEUP)~=0 and not gc:IsImmuneToEffect(e) and cm.fusiontg(e,tp,tc) and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
		local chkf=tp
		local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(cm.filter0),tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_EXTRA,0,nil,e)
		local sg1=Duel.GetMatchingGroup(cm.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf,gc)
		local mg2=nil
		local sg2=nil
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			sg2=Duel.GetMatchingGroup(cm.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf,gc)
		end
		if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,gc,chkf)
				tc:SetMaterial(mat1)
				Duel.SendtoDeck(mat1,tp,3,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				Duel.BreakEffect()
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			else
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,gc,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
	end
end
function cm.fdfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFacedown() or c:IsLocation(LOCATION_HAND)
end
function cm.fdfilter2(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)
end
