--舞狮舞风神·赫气烟翎
local cm,m,o=GetID()
function cm.initial_effect(c)
    Duel.LoadScript("c11100117.lua")
    aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_WARRIOR),1)
    c:EnableReviveLimit()
    --attack limit
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,LOCATION_MZONE)
    e2:SetCondition(cm.atcon)
    e2:SetValue(cm.atlimit)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(m,0))
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,m)
    e3:SetCondition(cm.con)
    e3:SetTarget(cm.tg)
    e3:SetOperation(cm.op)
    c:RegisterEffect(e3)
end
function cm.atcon(e)
    local tp=e:GetHandlerPlayer()
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and Duel.IsExistingMatchingCard(function(c) return c:IsRace(RACE_BEAST) and c:IsFaceup() end,tp,LOCATION_MZONE,0,1,nil)
end
function cm.atlimit(e,c)
    return c:IsFacedown() or not c:IsRace(RACE_BEAST)
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return rc:IsType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and rc:IsSetCard(0xa64) and rp==tp
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
    Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.NegateRelatedChain(tc,RESET_TURN_SET)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetValue(RESET_TURN_SET)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2)
    end
end