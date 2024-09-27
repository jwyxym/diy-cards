--
local cm,m,o=GetID()
function cm.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,m)
    e1:SetOperation(cm.activate)
    c:RegisterEffect(e1)
    --deckdes
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DECKDES)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_LEAVE_GRAVE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,m+30)
    e2:SetCondition(cm.con)
    e2:SetTarget(cm.tg)
    e2:SetOperation(cm.op)
    c:RegisterEffect(e2)
    --race
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CHANGE_RACE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e3:SetTarget(aux.TargetBoolFunction(cm.filter))
    e3:SetValue(RACE_MACHINE)
    c:RegisterEffect(e3)
end
function cm.thfilter(c)
    return c:IsSetCard(0x310) and c:IsAbleToHand()
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(cm.thfilter,tp,LOCATION_DECK,0,nil)
    if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g:Select(tp,1,1,nil)
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
    end
end
function cm.cfilter(c,tp)
    return c:IsSetCard(0x310) and c:IsControler(tp)
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(cm.cfilter,1,nil,tp)
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetDecktopGroup(tp,1)
    local ct=g:GetCount()
    if ct==1 and Duel.SendtoGrave(g,REASON_EFFECT) and g:GetFirst():IsLocation(LOCATION_GRAVE) and g:GetFirst():IsRace(RACE_MACHINE) and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(m,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        if sg:GetCount()>0 then
            Duel.HintSelection(sg)
            Duel.Destroy(sg,REASON_EFFECT)
        end
    end
end
function cm.filter(c)
    return c:IsLocation(LOCATION_MZONE) and c:IsPosition(POS_FACEUP) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end