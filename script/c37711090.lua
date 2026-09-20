--悖论特遣队 爆弹
function c37711090.initial_effect(c)
	--act in hand
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(37711090,0))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(c37711090.handcon)
	c:RegisterEffect(e0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,37711090)
	e1:SetTarget(c37711090.target)
	e1:SetOperation(c37711090.activate)
	c:RegisterEffect(e1)
	--set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37711090,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,37711090+1)
	e2:SetCondition(c37711090.setcon)
	e2:SetTarget(c37711090.settg)
	e2:SetOperation(c37711090.setop)
	c:RegisterEffect(e2)
end
function c37711090.hcfilter(c)
	return c:IsSetCard(0x2a9) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
function c37711090.handcon(e)
	return Duel.IsExistingMatchingCard(c37711090.hcfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function c37711090.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c37711090.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		if Duel.Destroy(g,REASON_EFFECT)==0 or not e:IsHasType(EFFECT_TYPE_ACTIVATE) or Duel.GetCurrentChain()<3 then return end
		local tc=Duel.GetOperatedGroup():GetFirst()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
		e1:SetTarget(c37711090.distg1)
		e1:SetLabelObject(tc)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVING)
		e2:SetCondition(c37711090.discon)
		e2:SetOperation(c37711090.disop)
		e2:SetLabelObject(tc)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
		e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e3:SetTarget(c37711090.distg2)
		e3:SetLabelObject(tc)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
	end
end
function c37711090.distg1(e,c)
	local tc=e:GetLabelObject()
	if c:IsType(TYPE_SPELL+TYPE_TRAP) then
		return c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
	else
		return c:IsOriginalCodeRule(tc:GetOriginalCodeRule()) and (c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0)
	end
end
function c37711090.distg2(e,c)
	local tc=e:GetLabelObject()
	return c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
function c37711090.discon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return re:GetHandler():IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
function c37711090.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function c37711090.setcon(e,tp,eg,ep,ev,re,r,rp)
	return ev>=3
end
function c37711090.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
end
function c37711090.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SSet(tp,c)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(37711090,0))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCost(c37711090.excost)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
function c37711090.excost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
end
