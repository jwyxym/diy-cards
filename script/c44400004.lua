--绮饿罗·狂爱龙娘
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+10000)
	e2:SetTarget(s.grtg)
	e2:SetOperation(s.grop)
	c:RegisterEffect(e2)
	local e3a=e2:Clone()
	e3a:SetType(EFFECT_TYPE_QUICK_O)
	e3a:SetCode(EVENT_CHAINING)
	e3a:SetCondition(s.con)
	c:RegisterEffect(e3a)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
end
	if not aux.checktpfusionhack then
		aux.checktpfusionhack=true
		gm_hack_fusion_check=Card.CheckFusionMaterial
		function Card.CheckFusionMaterial(card,Group_fus,Card_g,int_chkf,not_mat)
			local exg=Duel.GetMatchingGroup(s.getexc,int_chkf,0,LOCATION_MZONE,nil)
			if Group_fus==nil then Group_fus=Group.CreateGroup() end
			if exg:GetCount()>0 then
				Group_fus:Merge(exg)
			end
			return gm_hack_fusion_check(card,Group_fus,Card_g,int_chkf,not_mat)
		end
	end
end
function s.getexc(c)
	return c:GetFlagEffect(id)>0 and c:IsFaceup()
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return e:GetHandler()~=re:GetHandler() 
	and ((Duel.IsMainPhase() and Duel.GetTurnPlayer()==tp) or (Duel.GetTurnPlayer()~=tp and c:IsHasEffect(44400000) and Duel.IsCanRemoveCounter(tp,1,0,0x444,1,REASON_COST)))
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsSummonType(SUMMON_TYPE_FUSION) then
			Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
		end
		tc=eg:GetNext()
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and Duel.GetFlagEffect(0,id)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		if Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
			local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
			local tc=g:GetFirst()
			if tc then
				tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(aux.Stringid(id,3))
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
				e1:SetValue(s.matval)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
				tc:RegisterEffect(e2)
				local e3=e1:Clone()
				e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
				tc:RegisterEffect(e3)
				local e4=e1:Clone()
				e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
				tc:RegisterEffect(e4)
			end
		end
	end
end

function s.filter1(c,e)
	return c:IsSetCard(0x444) and not c:IsImmuneToEffect(e)
end
function s.filter20(c,e)
	return c:IsSetCard(0x444)
end
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.fcheck(tp,sg,fc)
	return sg:GetCount()<=3
end
function s.matval(e,c)
	return e:GetHandlerPlayer()==c:GetControler()
end
function s.grfilter(c,e,tp)
	return c:IsSetCard(0x444) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.grtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.grfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.grfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
		if Duel.GetTurnPlayer()~=tp and Duel.IsExistingMatchingCard(s.desfilter10,tp,LOCATION_FZONE,0,1,nil) then
		Duel.SelectMatchingCard(tp,s.desfilter10,tp,LOCATION_FZONE,0,1,1,nil):GetFirst():RemoveCounter(tp,0x444,1,REASON_COST)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.grfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.desfilter10(c)
	return c:IsCode(44400000)
end
function s.grop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT) and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
end
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp,LOCATION_MZONE+LOCATION_GRAVE):Filter(s.filter1,nil,e)
		aux.FCheckAdditional=s.fcheck
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		aux.FCheckAdditional=nil
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
	end
end
		if res and Duel.GetCurrentChain()>1 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp,LOCATION_MZONE+LOCATION_GRAVE):Filter(s.filter1,nil,e)
		aux.FCheckAdditional=s.fcheck
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
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			Duel.HintSelection(mat1)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local ag=mat1:Filter(s.filter20,nil,e):Select(tp,1,1,nil)
			if Duel.Remove(ag,POS_FACEUP,REASON_EFFECT)~=0 then
			mat1:Sub(ag)
			Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	aux.FCheckAdditional=nil
end
end
end

