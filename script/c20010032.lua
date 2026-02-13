--
function c20010032.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	--search
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(20010032,0))
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetCountLimit(1,20010032)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCost(c20010032.cost)
	e0:SetTarget(c20010032.tg)
	e0:SetOperation(c20010032.op)
	c:RegisterEffect(e0)
	--pos
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20010032,1))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c20010032.poscon)
	e1:SetCost(c20010032.poscost)
	e1:SetTarget(c20010032.postg)
	e1:SetOperation(c20010032.posop)
	c:RegisterEffect(e1)
end
function c20010032.filter(c,tp)
	return c:IsCode(20010010) and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(c20010032.thfilter,tp,LOCATION_DECK,0,1,c,c:GetType())
end
function c20010032.thfilter(c,type1)
	return c:IsCode(20010010) and not c:IsType(type1) and c:IsAbleToHand()
end
function c20010032.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function c20010032.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(c20010032.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c20010032.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,tp)
	e:SetLabel(0,g:GetFirst():GetType())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c20010032.op(e,tp,eg,ep,ev,re,r,rp)
	local label,type1=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c20010032.thfilter,tp,LOCATION_DECK,0,1,1,nil,type1)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c20010032.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb33)
end
function c20010032.poscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c20010032.cfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
function c20010032.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c20010032.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function c20010032.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c20010032.posfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c20010032.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c20010032.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function c20010032.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end