--械鳞龙魄 歼灭
function c31280187.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,31280187+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c31280187.condition)
	e1:SetTarget(aux.nbtg)
	e1:SetOperation(c31280187.activate)
	c:RegisterEffect(e1)
	--攻击上升
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c31280187.target)
	e2:SetOperation(c31280187.operation)
	c:RegisterEffect(e2)
end
function c31280187.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xca4) and c:GetOriginalType()&TYPE_MONSTER>0
end
function c31280187.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c31280187.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and rp==1-tp and Duel.IsChainNegatable(ev)
end
function c31280187.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) 
    	and Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,c31280187.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
		Duel.HintSelection(g)
		Duel.BreakEffect()
		Duel.Destroy(g,REASON_EFFECT)             
	end
end
function c31280187.atkfilter(c,e)
	return c:IsFaceup() and not c:IsImmuneToEffect(e) and c:IsRace(RACE_DRAGON)
end
function c31280187.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280187.atkfilter,tp,LOCATION_MZONE,0,1,nil,e) end
end
function c31280187.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c31280187.atkfilter,tp,LOCATION_MZONE,0,nil,e)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(200)
		tc:RegisterEffect(e1)
	end
end