--山樱剑技-追星剑
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,61100541)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.rscon)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
	
end
function s.rscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.filter3(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter3,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SelectTarget(tp,s.filter3,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.filter1(c,tp)
	return c:IsType(TYPE_TRAP) and c:IsSetCard(0x57b) and not c:IsCode(id) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end
function s.filter2(c,hc)
	return c:IsFaceup() and c:IsSetCard(0x57b) and c~=hc
end
function s.filter3(c,e,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsSetCard(0x57b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.ffilter(c,e,tp,hc)
	local sl=math.floor((c:GetLevel()-4)/2)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x57b) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,sl,nil,hc,e) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.spfilter(c,hc,e)
	return c:IsFaceup() and c:IsSetCard(0x57b) and c:IsDestructable(e) and c~=hc
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0) then return end
	local g=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,0,nil,tc)
	local b1=Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,tc)
	local b3=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil,tp)
	if #g>0 and (b1 or b2 or b3) then
		local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)},{b3,aux.Stringid(id,2)},{true,aux.Stringid(id,3)})
		if op==1 then
		local jg=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,0,1,#jg,nil,tc)
		Duel.Destroy(dg,REASON_EFFECT)
		if #jg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
			local tg=jg:Select(tp,1,#dg,nil)
			local tc=tg:GetFirst()
			while tc do
				Duel.NegateRelatedChain(tc,RESET_TURN_SET)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e2)
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_DISABLE_EFFECT)
				e3:SetValue(RESET_TURN_SET)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
				tc=tg:GetNext()
				end
			end
		elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local dg=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
		local fc=dg:GetFirst()
		if fc then
			local sl=math.floor((fc:GetLevel()-4)/2)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)	
			local oppg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_MZONE,0,sl,sl,nil,tc,e)
			if #oppg>0 and Duel.Destroy(oppg,REASON_EFFECT)==#oppg then
				Duel.SpecialSummon(fc,0,tp,tp,true,false,POS_FACEUP)
			end
		end
		elseif op==3 then
		ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
		local oppg=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_DECK,0,nil)
		if (ct>#oppg) then ct=#oppg end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,0,1,ct,nil,tc)
		local sdg=Duel.Destroy(dg,REASON_EFFECT)
		if #oppg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local dg=oppg:Select(tp,1,#dg,nil)
			local dc=dg:GetFirst()
			while dc do
				Duel.SSet(tp,dc,REASON_EFFECT)
				dc=dg:GetNext()
				end
			end
		end
	end
end
function s.filter(c)
	return c:IsFaceup() and c:IsCode(61100541)
end
function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end