--山樱的传说「葵」
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddLinkProcedure(c,s.fs,2,2,s.lcheck)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id+10000)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
	
end
function s.fs(c)
	return c:IsRace(RACE_BEASTWARRIOR)
end
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x57b)
end
function s.fs2(c)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsDiscardable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_HAND,0,1,nil,RACE_BEASTWARRIOR) end
	Duel.DiscardHand(tp,s.fs2,1,1,REASON_COST,nil)
end

function s.thfilter(c)
	return c:IsSetCard(0x57b) and c:IsAbleToHand()
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,0,0)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		if Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
function s.filter3(c,e)
	return not c:IsImmuneToEffect(e) and e:GetHandler():GetLinkedGroup():IsContains(c)
end
function s.filter4(c,e)
	return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsSetCard(0x57b) and c:IsType(TYPE_FUSION)
end
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_BEASTWARRIOR) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp,LOCATION_MZONE+LOCATION_GRAVE)
		if Duel.IsExistingMatchingCard(s.filter4,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e) then
		local mg3=Duel.GetFusionMaterial(1-tp,LOCATION_MZONE):Filter(s.filter3,nil,e)
		mg1:Merge(mg3)
	end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_ADD_FUSION_CODE)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetValue(61100531)
		Duel.RegisterEffect(e1,tp)
		local e1a=Effect.CreateEffect(e:GetHandler())
		e1a:SetType(EFFECT_TYPE_FIELD)
		e1a:SetCode(EFFECT_ADD_FUSION_CODE)
		e1a:SetTargetRange(0,LOCATION_MZONE)
		e1a:SetValue(61100532)
		Duel.RegisterEffect(e1a,tp)
		local e1b=Effect.CreateEffect(e:GetHandler())
		e1b:SetType(EFFECT_TYPE_FIELD)
		e1b:SetCode(EFFECT_ADD_FUSION_CODE)
		e1b:SetTargetRange(0,LOCATION_MZONE)
		e1b:SetValue(61100534)
		Duel.RegisterEffect(e1b,tp)
		local e1c=Effect.CreateEffect(e:GetHandler())
		e1c:SetType(EFFECT_TYPE_FIELD)
		e1c:SetCode(EFFECT_ADD_FUSION_CODE)
		e1c:SetTargetRange(0,LOCATION_MZONE)
		e1c:SetValue(61100535)
		Duel.RegisterEffect(e1c,tp)
		local e1d=Effect.CreateEffect(e:GetHandler())
		e1d:SetType(EFFECT_TYPE_FIELD)
		e1d:SetCode(EFFECT_ADD_FUSION_CODE)
		e1d:SetTargetRange(0,LOCATION_MZONE)
		e1d:SetValue(61100538)
		Duel.RegisterEffect(e1d,tp)
		local e1e=Effect.CreateEffect(e:GetHandler())
		e1e:SetType(EFFECT_TYPE_FIELD)
		e1e:SetCode(EFFECT_ADD_FUSION_CODE)
		e1e:SetTargetRange(0,LOCATION_MZONE)
		e1e:SetValue(61100539)
		Duel.RegisterEffect(e1e,tp)
		local e1f=Effect.CreateEffect(e:GetHandler())
		e1f:SetType(EFFECT_TYPE_FIELD)
		e1f:SetCode(EFFECT_ADD_FUSION_CODE)
		e1f:SetTargetRange(0,LOCATION_MZONE)
		e1f:SetValue(61100542)
		Duel.RegisterEffect(e1f,tp)
		local e1g=Effect.CreateEffect(e:GetHandler())
		e1g:SetType(EFFECT_TYPE_FIELD)
		e1g:SetCode(EFFECT_ADD_FUSION_CODE)
		e1g:SetTargetRange(0,LOCATION_MZONE)
		e1g:SetValue(61100545)
		Duel.RegisterEffect(e1g,tp)
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		e1:Reset()
		e1a:Reset()
		e1b:Reset()
		e1c:Reset()
		e1d:Reset()
		e1e:Reset()
		e1f:Reset()
		e1g:Reset()
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp,LOCATION_MZONE+LOCATION_GRAVE):Filter(s.filter1,nil,e)
	if Duel.IsExistingMatchingCard(s.filter4,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e) then
	local mg3=Duel.GetFusionMaterial(1-tp,LOCATION_MZONE):Filter(s.filter3,nil,e)
	mg1:Merge(mg3)
	end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_ADD_FUSION_CODE)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetValue(61100531)
		Duel.RegisterEffect(e1,tp)
		local e1a=Effect.CreateEffect(e:GetHandler())
		e1a:SetType(EFFECT_TYPE_FIELD)
		e1a:SetCode(EFFECT_ADD_FUSION_CODE)
		e1a:SetTargetRange(0,LOCATION_MZONE)
		e1a:SetValue(61100532)
		Duel.RegisterEffect(e1a,tp)
		local e1b=Effect.CreateEffect(e:GetHandler())
		e1b:SetType(EFFECT_TYPE_FIELD)
		e1b:SetCode(EFFECT_ADD_FUSION_CODE)
		e1b:SetTargetRange(0,LOCATION_MZONE)
		e1b:SetValue(61100534)
		Duel.RegisterEffect(e1b,tp)
		local e1c=Effect.CreateEffect(e:GetHandler())
		e1c:SetType(EFFECT_TYPE_FIELD)
		e1c:SetCode(EFFECT_ADD_FUSION_CODE)
		e1c:SetTargetRange(0,LOCATION_MZONE)
		e1c:SetValue(61100535)
		Duel.RegisterEffect(e1c,tp)
		local e1d=Effect.CreateEffect(e:GetHandler())
		e1d:SetType(EFFECT_TYPE_FIELD)
		e1d:SetCode(EFFECT_ADD_FUSION_CODE)
		e1d:SetTargetRange(0,LOCATION_MZONE)
		e1d:SetValue(61100538)
		Duel.RegisterEffect(e1d,tp)
		local e1e=Effect.CreateEffect(e:GetHandler())
		e1e:SetType(EFFECT_TYPE_FIELD)
		e1e:SetCode(EFFECT_ADD_FUSION_CODE)
		e1e:SetTargetRange(0,LOCATION_MZONE)
		e1e:SetValue(61100539)
		Duel.RegisterEffect(e1e,tp)
		local e1f=Effect.CreateEffect(e:GetHandler())
		e1f:SetType(EFFECT_TYPE_FIELD)
		e1f:SetCode(EFFECT_ADD_FUSION_CODE)
		e1f:SetTargetRange(0,LOCATION_MZONE)
		e1f:SetValue(61100542)
		Duel.RegisterEffect(e1f,tp)
		local e1g=Effect.CreateEffect(e:GetHandler())
		e1g:SetType(EFFECT_TYPE_FIELD)
		e1g:SetCode(EFFECT_ADD_FUSION_CODE)
		e1g:SetTargetRange(0,LOCATION_MZONE)
		e1g:SetValue(61100545)
		Duel.RegisterEffect(e1g,tp)
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
		e1:Reset()
		e1a:Reset()
		e1b:Reset()
		e1c:Reset()
		e1d:Reset()
		e1e:Reset()
		e1f:Reset()
		e1g:Reset()
end