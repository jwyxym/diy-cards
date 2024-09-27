--乐园妖精的回忆
local this,id,ofs=GetID()
function this.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(this.tg)
    e1:SetOperation(this.op)
    c:RegisterEffect(e1)
end
function this.thfilter(c)
    return c:IsCode(76200351) and c:IsAbleToHand()
end
function this.exfilter(c)
    return (c:IsAbleToGrave() or c:IsAbleToRemove()) and c:IsType(TYPE_LINK)
end
function this.tgfilter(c,tp)
    local at=c:GetOriginalAttribute()
    local b
    if at&ATTRIBUTE_LIGHT>0 then
        b = b or c:IsAbleToHand() and Duel.IsExistingMatchingCard(this.thfilter,tp,LOCATION_DECK,0,1,nil)
    elseif at&ATTRIBUTE_WATER>0 then
        b = b or c:IsDestructable() and Duel.IsExistingMatchingCard(this.exfilter,tp,LOCATION_EXTRA,0,1,nil)
    else return false
    end
    return b
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and this.tgfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(this.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc=Duel.SelectTarget(tp,this.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
    local at=tc:GetOriginalAttribute()
    e:SetLabel(at)
    if at&ATTRIBUTE_LIGHT>0 then
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,tp,LOCATION_MZONE)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
    elseif at&ATTRIBUTE_WATER>0 then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
    end
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end
    local at=e:GetLabel()
    if at&ATTRIBUTE_LIGHT>0 then
        if Duel.SendtoHand(tc,tp,REASON_EFFECT)>0 then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local tc2=Duel.SelectMatchingCard(tp,this.thfilter,tp,LOCATION_DECK,0,1,1,nil)
            if tc2 and #tc2>0 then
                Duel.SendtoHand(tc2,tp,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,tc2)
            end
        end
    elseif at&ATTRIBUTE_WATER>0 then
        if Duel.Destroy(tc,REASON_EFFECT)>0 then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
            local tc2=Duel.SelectMatchingCard(tp,this.exfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
            if not tc2 then return end
            local op=Duel.SelectOption(tp,{aux.Stringid(id,0),tc2:IsAbleToGrave()},{aux.Stringid(id,1),tc2:IsAbleToRemove()})
            if op==0 then Duel.SendtoGrave(tc2,REASON_EFFECT)
            elseif op==1 then Duel.Remove(tc2,POS_FACEUP,REASON_EFFECT)
            end
        end
    end
end
