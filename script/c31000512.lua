--希望姬之章·混沌之姬选
function c31000512.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e0)
	--SpecialSummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31000512,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,31000512)
	e1:SetCondition(c31000512.condition)
	e1:SetCost(c31000512.cost)
	e1:SetTarget(c31000512.target)
	e1:SetOperation(c31000512.operation)
	c:RegisterEffect(e1)
	--SpecialSummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31000512,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,31000512+1)
	e2:SetCondition(c31000512.condition2)
	e2:SetCost(c31000512.cost2)
	e2:SetTarget(c31000512.target2)
	e2:SetOperation(c31000512.operation2)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(31000512,ACTIVITY_CHAIN,c31000512.chainfilter)
end
function c31000512.chainfilter(re,tp,cid)
	return re:GetHandler():GetOriginalType()&(TYPE_MONSTER)==0
end
function c31000512.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x314) and c:IsType(TYPE_MONSTER)
end
function c31000512.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c31000512.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
function c31000512.afilter(c)
	return c:IsSetCard(0xa) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c31000512.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function c31000512.spfilter(c,e,tp)
	return c:IsSetCard(0xd11,0xd12) and c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c31000512.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31000512.spfilter,tp,0x13,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
function c31000512.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c31000512.spfilter,tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c31000512.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCustomActivityCount(31000512,1-tp,ACTIVITY_CHAIN)~=0	
		and Duel.GetTurnPlayer()==tp and Duel.IsMainPhase()
end
function c31000512.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function c31000512.spfilter2(c,e,tp)
	return c:IsSetCard(0x314) and c:IsType(TYPE_SYNCHRO) and Duel.GetLocationCountFromEx(tp)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function c31000512.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31000512.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c31000512.operation2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c31000512.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,1,nil)
	if sg:GetCount()>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local tc=sg:GetFirst()
		tc:RegisterFlagEffect(31000512,RESET_EVENT+RESETS_STANDARD,0,1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabelObject(tc)
		e1:SetCondition(c31000512.rmcon)
		e1:SetOperation(c31000512.rmop)
		Duel.RegisterEffect(e1,tp)
	end
end
function c31000512.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(31000512)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
function c31000512.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end