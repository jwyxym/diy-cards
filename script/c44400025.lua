--诡异之辉
local s,id,o=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(s.actlimit)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetOperation(s.regop3)
	e3:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O) 
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMING_MAIN_END,TIMINGS_CHECK_MONSTER)
	e4:SetRange(LOCATION_SZONE)  
	e4:SetCountLimit(1,id)   
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	
end
function s.actlimit(e,re,tp)
	local rc=re:GetHandler()
	return rc:GetCounter(0x1444)>0 and Duel.GetCurrentChain()>1
end
function s.regop3(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentChain()>2 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_END)
		e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_CHAIN)
		e1:SetOperation(s.regop2)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.regop2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(c)
	local ng=g:Filter(Card.IsLocation,nil,LOCATION_ONFIELD)
	if #ng<2 then
		c:AddCounter(0x1444,1)
		elseif #ng~=0 then
	local tc=ng:Select(tp,1,1,nil):GetFirst()
		tc:AddCounter(0x1444,1)
	end
		e:Reset()
end
function s.ctfilter(c)
	return c:IsFaceup() and c:GetCounter(0x1444)>0 and c:IsAbleToGrave()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x444) and (c:IsType(TYPE_FUSION) or c:IsType(TYPE_SYNCHRO))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rlfilter(c)
	return c:IsType(TYPE_FUSION) or c:IsType(TYPE_SYNCHRO)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(s.rlfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.rlfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
	local g=Duel.GetMatchingGroup(s.rlfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,nil)
	return b1 and b2
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsAbleToGrave()
			and Duel.IsExistingMatchingCard(s.ctfilter,tp,0,LOCATION_MZONE,1,nil)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,tp,LOCATION_SZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g==0 then return end
	g:AddCard(c)
	if Duel.SendtoGrave(g,REASON_EFFECT)~=2 then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if not sc then return end
	local sumtype
	if sc:IsType(TYPE_FUSION) then
		sumtype=SUMMON_TYPE_FUSION
	elseif sc:IsType(TYPE_SYNCHRO) then
		sumtype=SUMMON_TYPE_SYNCHRO 
	end
	if Duel.SpecialSummon(sc,sumtype,tp,tp,false,false,POS_FACEUP)>0 then
		sc:CompleteProcedure()
	end
end