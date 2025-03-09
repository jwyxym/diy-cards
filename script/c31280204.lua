--莱欧斯小队-奇遇！？
function c31280204.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,31280204)
	e1:SetTarget(c31280204.target)
	e1:SetOperation(c31280204.activate)
	c:RegisterEffect(e1)
	--set
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,31280204)
	e2:SetCondition(c31280204.setcon)
	e2:SetTarget(c31280204.settg)
	e2:SetOperation(c31280204.setop)
	c:RegisterEffect(e2)
end
c31280204.SetCard_TnT_Lwsteam=true 
function c31280204.filter(c)
	return c:IsSetCard(0x3a21) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c31280204.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280204.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c31280204.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c31280204.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c31280204.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
function c31280204.tdfil(c) 
	return c:IsAbleToDeck() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x3a21) and c:IsFaceup()
end 
function c31280204.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) 
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c31280204.tdfil(chkc) end 
	if chk==0 then return e:GetHandler():IsSSetable() and Duel.IsExistingTarget(c31280204.tdfil,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	local g=Duel.SelectTarget(tp,c31280204.tdfil,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil) 
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function c31280204.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		Duel.SSet(tp,c) 
	end
end
