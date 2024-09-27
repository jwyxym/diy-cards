--舞狮舞炎神·寒气银岭
local cm,m,o=GetID()
function cm.initial_effect(c)
    Duel.LoadScript("c11100117.lua")
    aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_SPELLCASTER),1)
    c:EnableReviveLimit()
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(m,0))
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,m)
    e1:SetCondition(cm.con)
    e1:SetTarget(cm.tg)
    e1:SetOperation(cm.op)
    c:RegisterEffect(e1)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetRange(LOCATION_FZONE)
    e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(function (e,tc)
        return tc:IsSetCard(0xa64) and tc:IsFaceupEx() and tc~=e:GetHandler()
    end)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function cm.filter(c)
    return c:IsSetCard(0xa64) and c:IsAbleToHand()
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    local loc=LOCATION_GRAVE+LOCATION_REMOVED
    if Duel.IsExistingMatchingCard(function(c) return c:IsRace(RACE_BEAST) and c:IsFaceupEx() end,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) then loc=loc+LOCATION_DECK end
    if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,loc,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,loc)
end
function cm.op(e,tp,eg,ep,ev,re,r,rp) 
    local loc=LOCATION_GRAVE+LOCATION_REMOVED
    if Duel.IsExistingMatchingCard(function(c) return c:IsRace(RACE_BEAST) and c:IsFaceupEx() end,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) then loc=loc+LOCATION_DECK end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cm.filter),tp,loc,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end