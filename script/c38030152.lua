--爱绝的飞翔
function c38030152.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,38030152+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c38030152.target)
	e1:SetOperation(c38030152.activate)
	c:RegisterEffect(e1)
	--recover
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,38030152)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c38030152.rectg)
	e2:SetOperation(c38030152.recop)
	c:RegisterEffect(e2)
end
function c38030152.tfilter(c)
	return c:IsCode(38030161) and c:IsFaceup()
end
function c38030152.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c38030152.tfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c38030152.tfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsAbleToEnterBP() and Duel.GetTurnPlayer()==tp end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c38030152.tfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c38030152.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() or tc:IsFacedown() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end
function c38030152.recfilter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
function c38030152.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c38030152.recfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c38030152.recfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,c38030152.recfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local atk=g:GetFirst():GetAttack()
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,atk)
end
function c38030152.recop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
	end
end
