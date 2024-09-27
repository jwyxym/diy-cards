--穹瀛之仙身
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=aux.AddRitualProcGreater2(c,this.rfilter,nil,this.rmfilter,nil,true)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND|CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetTarget(this.thtg)
    e2:SetOperation(this.thop)
    c:RegisterEffect(e2)
end
function this.rfilter(c)
    return c:IsSetCard(0x675)
end
function this.rmfilter(c)
    return c:IsRace(RACE_SPELLCASTER|RACE_WARRIOR)
end
function this.thfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x675) and c:IsAbleToDeck()
end
function this.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and this.thfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(this.thfilter,tp,LOCATION_REMOVED,0,1,nil) and e:GetHandler():IsAbleToHand() end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,this.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
function this.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and Duel.SendtoHand(c,tp,REASON_EFFECT)>0
    and tc:IsRelateToEffect(e) then
        Duel.SendtoDeck(tc,tp,LOCATION_DECKSHF,REASON_EFFECT)
    end
end
