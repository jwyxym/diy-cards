--赎罪之桀刑
function c38030120.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)--TIMING_END_PHASE
	e1:SetDescription(aux.Stringid(38030120,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,38030120)
	e1:SetCondition(c38030120.spcon)
	e1:SetCost(c38030120.spcost)
	e1:SetTarget(c38030120.sptg)
	e1:SetOperation(c38030120.spop)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)--TIMING_END_PHASE
	e2:SetDescription(aux.Stringid(38030120,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,38030120)
	e2:SetTarget(c38030120.distg)
	e2:SetOperation(c38030120.disop)
	c:RegisterEffect(e2)
end
function c38030120.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2--Duel.IsMainPhase()
end
function c38030120.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function c38030120.spsumfilter1(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp)
end
function c38030120.spsumfilter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
function c38030120.spgcheck(g,e,tp)
	if not aux.gfcheck(g,Card.IsCode,38030100,38030102) then return false end
	local ac=g:GetFirst()
	local bc=g:GetNext()
	return c38030120.spsumfilter1(ac,e,tp) and c38030120.spsumfilter2(bc,e,tp)
		or c38030120.spsumfilter1(bc,e,tp) and c38030120.spsumfilter2(ac,e,tp)
end
function c38030120.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,38030100,38030102)
	if chk==0 then
		local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)
		return not Duel.IsPlayerAffectedByEffect(tp,59822133) and ft1>0 and ft2>0
			and g:CheckSubGroup(c38030120.spgcheck,2,2,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,PLAYER_ALL,LOCATION_DECK+LOCATION_GRAVE)
end
function c38030120.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or ft1<=0 or ft2<=0 then return end
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,38030100,38030102)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:SelectSubGroup(tp,c38030120.spgcheck,false,2,2,e,tp)
	if not sg or #sg==0 then return end
	Duel.ConfirmCards(1-tp,sg)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(38030120,2))
	local g1=sg:FilterSelect(tp,c38030120.spsumfilter1,1,1,nil,e,tp)
	Duel.SpecialSummonStep(g1:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
	Duel.SpecialSummonStep((sg-g1):GetFirst(),0,tp,1-tp,false,false,POS_FACEUP)
	Duel.SpecialSummonComplete()
	if c38030120.fstg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(38030120,3)) then
		Duel.BreakEffect()
		c38030120.fsop(e,tp,eg,ep,ev,re,r,rp)
	end
end
function c38030120.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsFaceupEx() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
function c38030120.filter2(c,e,tp,m,f,chkf)
	return c:IsRace(RACE_FAIRY+RACE_FIEND) and c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function c38030120.fexfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
function c38030120.frcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function c38030120.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function c38030120.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local check=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetMatchingGroup(c38030120.filter1,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_EXTRA,0,nil,e)
		if check then
			local mg2=Duel.GetMatchingGroup(c38030120.fexfilter,tp,LOCATION_DECK,0,nil)
			if mg2:GetCount()>0 then
				mg1:Merge(mg2)
				aux.FCheckAdditional=c38030120.frcheck
				aux.GCheckAdditional=c38030120.gcheck
			end
		end
		local res=Duel.IsExistingMatchingCard(c38030120.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		aux.FCheckAdditional=nil
		aux.GCheckAdditional=nil
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(c38030120.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c38030120.fsop(e,tp,eg,ep,ev,re,r,rp)
	local check=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
	local chkf=tp
	local mg1=Duel.GetMatchingGroup(c38030120.filter1,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_EXTRA,0,nil,e)
	if check then
		local mg2=Duel.GetMatchingGroup(c38030120.fexfilter,tp,LOCATION_DECK,0,nil)
		if mg2:GetCount()>0 then
			mg1:Merge(mg2)
		end
		aux.FCheckAdditional=c38030120.frcheck
		aux.GCheckAdditional=c38030120.gcheck
	end
	local sg1=Duel.GetMatchingGroup(c38030120.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	aux.FCheckAdditional=nil
	aux.GCheckAdditional=nil
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(c38030120.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if check then
				aux.FCheckAdditional=c38030120.frcheck
				aux.GCheckAdditional=c38030120.gcheck
			end
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			aux.FCheckAdditional=nil
			aux.GCheckAdditional=nil
			tc:SetMaterial(mat1)
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
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
function c38030120.cfilter(c,tp)
	if not (c:IsRace(RACE_FAIRY+RACE_FIEND) and c:IsType(TYPE_FUSION) and c:IsFaceup()) then return false end
	return Duel.IsExistingMatchingCard(c38030120.disfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
function c38030120.disfilter(c,atk)
	return aux.NegateMonsterFilter(c) and c:IsAttackBelow(atk)
end
function c38030120.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c38030120.cfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(c38030120.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,c38030120.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function c38030120.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc then
		if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
		local sg=Duel.GetMatchingGroup(c38030120.disfilter,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
		if sg:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
			local sc=sg:Select(tp,1,1,nil):GetFirst()
			if sc and not sc:IsImmuneToEffect(e) then
				Duel.HintSelection(Group.FromCards(sc))
				Duel.NegateRelatedChain(sc,RESET_TURN_SET)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				sc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				sc:RegisterEffect(e2)
			end
		end
	end
end
