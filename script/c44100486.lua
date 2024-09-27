--诺艾尔 战衣着装
function c44100486.initial_effect(c)
	--Activate
	local e1=aux.AddRitualProcEqual2(c,c44100486.filter,LOCATION_HAND,c44100486.grfilter,c44100486.mfilter,true)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44100486,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,44100486)
	e2:SetCondition(c44100486.thcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44100486.thtg)
	e2:SetOperation(c44100486.thop)
	c:RegisterEffect(e2)
end
function c44100486.filter(c)
	return c:IsSetCard(0x44a)
end
function c44100486.grfilter(c)
	return c:IsSetCard(0x44a)
end
function c44100486.mfilter(c)
	return c:IsSetCard(0x44a)
end
function c44100486.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c44100486.thfilter(c,e,tp,turn)
	return c:IsType(TYPE_RITUAL) and c:IsSetCard(0x44a) and c:IsAbleToHand() and c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetTurnID()==turn
end
function c44100486.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local turn=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_EXTRA) and chkc:IsControler(tp) and c44100486.thfilter(chkc,e,tp,turn) end
	if chk==0 then return Duel.IsExistingTarget(c44100486.thfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,turn) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c44100486.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,turn)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c44100486.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
