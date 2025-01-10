--宇灾 死癌茅膏
function c47700018.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--change attribute
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,47700018)
	e1:SetTarget(c47700018.atttg)
	e1:SetOperation(c47700018.attop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c47700018.cost)
	e2:SetTarget(c47700018.tg)
	e2:SetOperation(c47700018.op)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA)
	e3:SetCountLimit(1,47700018+1)
	e3:SetCost(c47700018.spcost)
	e3:SetTarget(c47700018.sptg)
	e3:SetOperation(c47700018.spop)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(47700018,ACTIVITY_SPSUMMON,c47700018.counterfilter)
	--redirect
	aux.AddBanishRedirect(c,c47700018.recon)
end
function c47700018.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or (c:IsType(TYPE_FUSION) or c:IsSetCard(0x470))
end
function c47700018.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(47700018,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c47700018.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c47700018.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsType(TYPE_FUSION) or c:IsSetCard(0x470)) and c:IsLocation(LOCATION_EXTRA)
end
function c47700018.attfilter(c)
	return c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_DARK) and c:GetBaseAttack()>0
end
function c47700018.atttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c47700018.attfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c47700018.attfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c47700018.attfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetBaseAttack())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function c47700018.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(ATTRIBUTE_DARK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		if Duel.Recover(tp,tc:GetBaseAttack(),REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
			Duel.BreakEffect()
			Duel.Destroy(c,0x40)
		end
	end
end
function c47700018.spfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
function c47700018.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_DARK) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function c47700018.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp)
		local res=Duel.IsExistingMatchingCard(c47700018.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(c47700018.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c47700018.op(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(c47700018.spfilter1,nil,e)
	local sg1=Duel.GetMatchingGroup(c47700018.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(c47700018.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
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
function c47700018.rlfilter(c,ft,tp)
	return ft>0 or (c:IsControler(tp) and c:GetSequence()<5)
end
function c47700018.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c47700018.rlfilter,1,nil,ft,tp) end
	local sg=Duel.SelectReleaseGroup(tp,c47700018.rlfilter,1,1,nil,ft,tp)
	Duel.Release(sg,REASON_COST)
end
function c47700018.cfilter(c,tp,ck)
	return Duel.GetMZoneCount(tp,c)>0 or (ck==true and Duel.GetLocationCountFromEx(tp,tp,c,nil))
end
function c47700018.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ck=false
	if c:IsLocation(LOCATION_EXTRA) then ck=true end
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,c47700018.cfilter,1,REASON_COST,true,c,tp,ck)
		and Duel.GetCustomActivityCount(47700018,tp,ACTIVITY_SPSUMMON)==0 end
	local g=Duel.SelectReleaseGroupEx(tp,c47700018.cfilter,1,1,REASON_COST,true,c,tp,ck)
	Duel.Release(g,REASON_COST)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c47700018.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c47700018.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c47700018.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) then return end
	if Duel.GetLocationCountFromEx(tp)<=0 and c:IsLocation(LOCATION_EXTRA) then return end
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_DRAGON)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
function c47700018.recon(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
end
