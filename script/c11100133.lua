--幻念引梦士的恒动闹钟
local cm,m,o=GetID()
function cm.initial_effect(c)
    aux.AddCodeList(c,11100130)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW+CATEGORY_DICE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,m)
    e1:SetTarget(cm.thtg)
    e1:SetOperation(cm.thop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e3:SetCountLimit(1,m+o)
    e3:SetCondition(cm.con)
    e3:SetCost(aux.bfgcost)
    e3:SetOperation(cm.regop)
    c:RegisterEffect(e3)
end
cm.toss_dice=true
function cm.thfilter(c)
    return aux.IsCodeListed(c,11100130) and not c:IsCode(m) and c:IsAbleToHand()
end
function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
    local dc=Duel.TossDice(tp,1)
    if dc>3 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,cm.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if g:GetCount()>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    else
        if Duel.Draw(tp,2,REASON_EFFECT)==2 then
            Duel.ShuffleHand(tp)
            Duel.BreakEffect()
            Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
        end
    end
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return ep==tp and (rc:IsCode(11100130) or aux.IsCodeListed(rc,11100130))
end
function cm.regop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_TOSS_DICE_NEGATE)
    e1:SetCondition(cm.coincon)
    e1:SetOperation(cm.coinop)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function cm.coincon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,83241722)==0
end
function cm.coinop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp,83241722)~=0 then return end
    if Duel.SelectYesNo(tp,aux.Stringid(83241722,0)) then
        Duel.Hint(HINT_CARD,0,m)
        Duel.RegisterFlagEffect(tp,83241722,RESET_PHASE+PHASE_END,0,1)
        local ct1=bit.band(ev,0xff)
        local ct2=bit.rshift(ev,16)
        Duel.TossDice(ep,ct1,ct2)
    end
end