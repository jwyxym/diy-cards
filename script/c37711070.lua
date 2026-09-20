--悖论特遣队 讯号
function c37711070.initial_effect(c)
	--act in hand
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(37711070,0))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
	e0:SetCost(c37711070.excost)
	c:RegisterEffect(e0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,37711070)
	e1:SetTarget(c37711070.target)
	e1:SetOperation(c37711070.activate)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37711070,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,37711070+1)
	e2:SetCondition(c37711070.thcon)
	e2:SetTarget(c37711070.thtg)
	e2:SetOperation(c37711070.thop)
	c:RegisterEffect(e2)
end
function c37711070.excost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	tc:RegisterFlagEffect(37711070,RESET_EVENT+RESETS_STANDARD+EVENT_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(37711070,3))
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabelObject(tc)
	e1:SetCondition(c37711070.retcon)
	e1:SetOperation(c37711070.retop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c37711070.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(37711070)==0 then
		e:Reset()
		return false
	else
		return true
	end
end
function c37711070.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.SendtoHand(tc,tp,REASON_EFFECT)
end
function c37711070.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,37711070)==0 end
end
function c37711070.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,37711070)>0 then return end
	Duel.RegisterFlagEffect(tp,37711070,RESET_PHASE+PHASE_END,0,0)
	if Duel.GetCurrentChain()>=3 and e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(37711070,2)) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function c37711070.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ev>=3
end
function c37711070.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function c37711070.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end
