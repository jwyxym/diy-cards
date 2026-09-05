local s,id,o=GetID()
function s.initial_effect(c)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.damcon)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
function s.lcfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x74b) and c:IsLinkAbove(3)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.lcfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.exccon(e,tp,eg,ep,ev,re,r,rp)
end
function s.damfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x74b)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.damfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.damfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectTarget(tp,s.damfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	local dam=tc:GetLink()*300
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local dam=tc:GetLink()*300
		if dam>0 then
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end
