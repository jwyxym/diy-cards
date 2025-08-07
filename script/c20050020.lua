--仙境的美梦
function c20050020.initial_effect(c)
	aux.AddCodeList(c,19000032)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,20050020+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c20050020.cost)
	e1:SetTarget(c20050020.target)
	e1:SetOperation(c20050020.operation)
	c:RegisterEffect(e1)
end
function c20050020.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c20050020.cfilter1,1,nil,tp) or Duel.IsExistingMatchingCard(c20050020.costfilter,tp,LOCATION_GRAVE,0,1,nil) or Duel.IsExistingMatchingCard(c20050020.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function c20050020.cfilter1(c,tp)
	return (c:IsCode(19000032) or c:IsSetCard(0xb31)) and Duel.GetMZoneCount(tp,c)>0
end
function c20050020.spfilter1(c,e,tp)
	return c:IsCode(19000032)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c20050020.lvfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0xb31) or c:IsCode(19000032)) and c:IsLevelAbove(1)
end
function c20050020.costfilter(c)
	return (c:IsCode(20200003) or (aux.IsCodeListed(c,19000032) and c:IsType(TYPE_SPELL+TYPE_TRAP))) and c:IsAbleToRemoveAsCost() and not c:IsCode(20050020)
end
function c20050020.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20050020.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) or Duel.IsExistingMatchingCard(c20050020.lvfilter,tp,LOCATION_MZONE,0,1,nil) or Duel.GetFlagEffect(tp,20050020)==0 end
end
function c20050020.operation(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(c20050020.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.CheckReleaseGroup(tp,c20050020.cfilter1,1,nil,tp)
	local b2=Duel.IsExistingMatchingCard(c20050020.lvfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.GetFlagEffect(tp,20050020)==0
	local b3= Duel.IsExistingMatchingCard(c20050020.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(20050020,0)
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(20050020,1)
		opval[off-1]=2
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(20050020,2)
		opval[off-1]=3
		off=off+1
	end
	if off==1 then return end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		local g=Duel.SelectReleaseGroup(tp,c20050020.cfilter1,1,1,nil,tp)
		local sg1=Duel.Release(g,REASON_EFFECT)
		if sg1 then
			if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,c20050020.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	elseif opval[op]==2 then
			local g=Duel.GetMatchingGroup(c20050020.lvfilter,tp,LOCATION_MZONE,0,nil)
			local c=e:GetHandler()
			local tc=g:GetFirst()
			while tc do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(3)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
			end
	elseif opval[op]==3 then
			local g=Duel.SelectMatchingCard(tp,c20050020.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
			local sg2=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			if sg2 then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetTargetRange(LOCATION_MZONE,0)
				e1:SetCode(EFFECT_ADD_CODE)
				e1:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
				e1:SetValue(19000032)
				e1:SetReset(RESET_PHASE+PHASE_END,2)
				Duel.RegisterEffect(e1,tp)
				Duel.RegisterFlagEffect(tp,20050020,RESET_PHASE+PHASE_END,0,2)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_FIELD)
				e2:SetTargetRange(LOCATION_GRAVE,0)
				e2:SetCode(EFFECT_ADD_CODE)
				e2:SetValue(20200003)
				e2:SetReset(RESET_PHASE+PHASE_END,2)
				Duel.RegisterEffect(e2,tp)
				Duel.RegisterFlagEffect(tp,20050020,RESET_PHASE+PHASE_END,0,2)
			end
		end
end