--魂之一手
function c38030144.initial_effect(c)
	aux.AddCodeList(c,38030130)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,38030144+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c38030144.cost)
	e1:SetTarget(c38030144.target)
	e1:SetOperation(c38030144.activate)
	c:RegisterEffect(e1)
	--shuffle
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,38030144)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c38030144.atktg)
	e2:SetOperation(c38030144.atkop)
	c:RegisterEffect(e2)
end
function c38030144.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	Duel.PayLPCost(tp,2000)
end
function c38030144.thfilter(c)
	return c:IsCode(38030130,38030132,38030134,38030137) and c:IsAbleToHand()
end
function c38030144.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c38030144.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=2 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function c38030144.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c38030144.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	Duel.SendtoHand(tg,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tg)
end
function c38030144.tfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
function c38030144.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c38030144.tfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c38030144.tfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c38030144.tfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c38030144.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
