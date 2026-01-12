--
function c19990050.initial_effect(c)
	c:SetSPSummonOnce(19990050)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,c19990050.ffilter,2,true)
	--fusion
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19990050,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c19990050.tg)
	e1:SetOperation(c19990050.op)
	c:RegisterEffect(e1)
	--spsummon1
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19990050,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,19990050)
	e2:SetCondition(c19990050.spscon)
	e2:SetCost(c19990050.spscost)
	e2:SetTarget(c19990050.spstg)
	e2:SetOperation(c19990050.spsop)
	c:RegisterEffect(e2)
	--spsummon2
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19990050,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,19990050+100)
	e3:SetCondition(c19990050.spcon)
	e3:SetTarget(c19990050.sptg)
	e3:SetOperation(c19990050.spop)
	c:RegisterEffect(e3)
	--pendulum
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(19990050,3))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,19990050+200)
	e5:SetTarget(c19990050.pentg)
	e5:SetOperation(c19990050.penop)
	c:RegisterEffect(e5)
end
function c19990050.ffilter(c)
	return c:IsFusionSetCard(0xb30) or c:IsFusionSetCard(0xb29)
end
function c19990050.spsfilter(c)
	return c:IsSetCard(0xb29) and not c:IsCode(19990050)
end
function c19990050.spscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c19990050.spsfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
function c19990050.costfilter(c,tp)
	return c:IsSetCard(0xb30) and c:IsAbleToRemoveAsCost()
end
function c19990050.spscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19990050.costfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c19990050.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c19990050.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c19990050.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c19990050.filter0(c)
	return c:IsOnField() and c:IsAbleToRemove()
end
function c19990050.filter1(c,e)
	return c:IsOnField() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
function c19990050.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function c19990050.filter3(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
function c19990050.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(c19990050.filter0,nil)
		local mg2=Duel.GetMatchingGroup(c19990050.filter3,tp,LOCATION_GRAVE,0,nil)
		mg1:Merge(mg2)
		local res=Duel.IsExistingMatchingCard(c19990050.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(c19990050.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND)
end
function c19990050.op(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(c19990050.filter1,nil,e)
	local mg2=Duel.GetMatchingGroup(c19990050.filter3,tp,LOCATION_GRAVE,0,nil)
	mg1:Merge(mg2)
	local sg1=Duel.GetMatchingGroup(c19990050.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(c19990050.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
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
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
function c19990050.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and bit.band(r,REASON_EFFECT)~=0 and e:GetHandler():IsPreviousControler(tp)
end
function c19990050.spfilter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function c19990050.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19990050.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c19990050.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c19990050.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c19990050.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function c19990050.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end