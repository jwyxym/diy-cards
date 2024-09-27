--陨宇祀圣之眼
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(this.target)
	e1:SetOperation(this.activate)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_REMOVE)
    e2:SetCountLimit(1,id)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetTarget(this.tg)
    e2:SetOperation(this.op)
    c:RegisterEffect(e2)
end
function this.thfilter(c,tc)
	return not (c:IsRace(tc:GetRace()) and c:IsAttribute(tc:GetAttribute())) and c:IsSetCard(0xa63) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function this.cfilter(c,tp)
	return not c:IsPublic() and c:IsType(TYPE_MONSTER)
		and Duel.IsExistingMatchingCard(this.thfilter,tp,LOCATION_DECK,0,1,nil,c)
end
function this.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		and Duel.IsExistingMatchingCard(this.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,this.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	e:SetLabelObject(g:GetFirst())
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function this.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,this.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function this.filter(c)
    return c:IsSetCard(0xa63) and not c:IsCode(11130027) and c:IsFaceupEx() and c:IsAbleToHand()
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and this.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(this.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc=Duel.SelectTarget(tp,this.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil):GetFirst()
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,tp,tc:GetLocation())
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,tp,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end
end
