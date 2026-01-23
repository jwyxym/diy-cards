--伪升天仪式
function c20200026.initial_effect(c)
	aux.AddCodeList(c,20200027)
	local e1=aux.AddRitualProcGreater2(c,c20200026.filter,LOCATION_HAND+LOCATION_GRAVE,nil,nil,true)
	c:RegisterEffect(e1)
	--To hand
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_TOHAND)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetCost(aux.bfgcost)
	e0:SetTarget(c20200026.thtg)
	e0:SetOperation(c20200026.thop)
	c:RegisterEffect(e0)
end
function c20200026.filter(c)
	return c:IsCode(20200027)
end
function c20200026.thfilter(c)
	return c:IsCode(20200003) and c:IsFaceup() and c:IsAbleToHand()
end
function c20200026.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c20200026.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c20200026.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c20200026.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c20200026.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end