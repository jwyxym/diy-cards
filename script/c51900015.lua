--《无限·迷茫》
function c51900015.initial_effect(c)
	aux.AddCodeList(c,51900003) 
	--code
	aux.EnableChangeCode(c,24094653,LOCATION_GRAVE)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51900015,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN) 
	e1:SetTarget(c51900015.target)
	e1:SetOperation(c51900015.activate)
	c:RegisterEffect(e1)
end
c51900015.fusion_effect=true
function c51900015.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function c51900015.filter2(c,e)
	return not c:IsImmuneToEffect(e)
end
function c51900015.spfilter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and (not f or f(c)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function c51900015.chkfilter(c,tp)
	return c:IsControler(tp) and c:IsCode(51900003)
end
function c51900015.exfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
end
function c51900015.fcheck(tp,sg,fc)
	if sg:IsExists(c51900015.chkfilter,1,nil,tp) then
		return true 
	else
		return not sg:IsExists(c51900015.exfilter,1,nil,tp)
	end
end
function c51900015.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(c51900015.filter2,nil,e)
		local mg2=Duel.GetMatchingGroup(c51900015.filter1,tp,LOCATION_GRAVE,0,nil,e)
		if mg1:IsExists(c51900015.chkfilter,1,nil,tp) and mg2:GetCount()>0 or mg2:IsExists(c51900015.chkfilter,1,nil,tp) then
			mg1:Merge(mg2)
		end
		aux.FCheckAdditional=c51900015.fcheck
		local res=Duel.IsExistingMatchingCard(c51900015.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(c51900015.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		aux.FCheckAdditional=nil
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
end
function c51900015.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(c51900015.filter2,nil,e)
	local mg2=Duel.GetMatchingGroup(c51900015.filter1,tp,LOCATION_GRAVE,0,nil,e)
	if mg1:IsExists(c51900015.chkfilter,1,nil,tp) and mg2:GetCount()>0 or mg2:IsExists(c51900015.chkfilter,1,nil,tp) then
		mg1:Merge(mg2)
	end
	aux.FCheckAdditional=c51900015.fcheck
	local sg1=Duel.GetMatchingGroup(c51900015.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(c51900015.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			local mat2=mat1:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
			mat1:Sub(mat2)
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.Remove(mat2,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	aux.FCheckAdditional=nil
end


