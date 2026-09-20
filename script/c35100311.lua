--水界僭主的遗骸
function c35100311.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
    e1:SetCondition(c35100311.condition)
	e1:SetTarget(c35100311.target)
	e1:SetOperation(c35100311.operation)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c35100311.handcon)
	c:RegisterEffect(e2)
end
function c35100311.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:IsRace(RACE_AQUA+RACE_FISH+RACE_SEASERPENT)
end
function c35100311.rmfilter(c,tc,e,re,tp)
	return c:IsType(TYPE_MONSTER) and c:GetOriginalRace()==re:GetHandler():GetOriginalRace() and c:IsAbleToRemove()
end
function c35100311.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c35100311.rmfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
function c35100311.activate(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local bc=Duel.SelectMatchingCard(tp,c35100311.rmfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,ac):GetFirst()
	if bc and Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)~=0 and bc:IsLocation(LOCATION_REMOVED) then
        local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e1:SetTarget(c35100311.distg)
		e1:SetLabelObject(bc)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVING)
		e2:SetCondition(c35100311.discon)
		e2:SetOperation(c35100311.disop)
		e2:SetLabelObject(bc)
		e2:SetReset(RESET_PHASE+PHASE_END,2)
		Duel.RegisterEffect(e2,tp)
	end
end
function c35100311.distg(e,c)
	local bc=e:GetLabelObject()
	return c:IsOriginalCodeRule(bc:GetOriginalCodeRule()) and (c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0)
end
function c35100311.discon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsOriginalCodeRule(bc:GetOriginalCodeRule())
end
function c35100311.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end