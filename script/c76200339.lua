--乐园的妖精
local this,id,ofs=GetID()
function this.initial_effect(c)
    aux.AddCodeList(c,76200312)
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(this.tg)
    e1:SetOperation(this.op)
    c:RegisterEffect(e1)
end
function this.filter(c)
    return c:IsCode(76200307,76200312) and c:IsAbleToHand() and (c:IsLocation(LOCATION_DECK) or c:IsFaceup())
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(STATUS_JUST_POS,tp,HINTMSG_ATOHAND)
    local tc=Duel.SelectMatchingCard(tp,this.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
    if tc then
        Duel.SendtoHand(tc,tp,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end
end
