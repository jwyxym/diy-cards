--欢迎来到仙境
function c20200036.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,20200036+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c20200036.condition)
	e1:SetTarget(c20200036.target)
	e1:SetOperation(c20200036.operation)
	c:RegisterEffect(e1)
	--tohand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20200036,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c20200036.thtg)
	e2:SetOperation(c20200036.thop)
	c:RegisterEffect(e2)
end
function c20200036.actfilter(c)
	return c:IsCode(20200003) and c:IsFaceup()
end
function c20200036.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c20200036.actfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c20200036.filter(c)
	return c:IsType(TYPE_FIELD) and c:IsSetCard(0xb31,0xb32) and c:IsSSetable()
end
function c20200036.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c20200036.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>1 end
end
function c20200036.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c20200036.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if g:GetClassCount(Card.GetCode)<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(20200036,0))
	local tg1=g:Select(tp,1,1,nil)
	g:Remove(Card.IsCode,nil,tg1:GetFirst():GetCode())
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(20200036,1))
	local tg2=g:Select(tp,1,1,nil)
	Duel.SSet(tp,tg1)
	Duel.SSet(tp,tg2,1-tp)
	tg1:GetFirst():RegisterFlagEffect(20200036,RESET_EVENT+RESETS_STANDARD,0,1)
	tg2:GetFirst():RegisterFlagEffect(20200036,RESET_EVENT+RESETS_STANDARD,0,1)
end
function c20200036.thfilter(c)
	return c:IsFacedown() and c:IsAbleToHand()
end
function c20200036.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and c20200036.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c20200036.thfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=Duel.SelectTarget(tp,c20200036.thfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end
function c20200036.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end