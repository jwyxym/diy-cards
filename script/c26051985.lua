-- 跃音萌行 欢筵和奏
-- ID: 26051985
-- 字段：跃音萌行 0x906
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.reccon)
    e2:SetOperation(s.recop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
end
function s.thfilter(c)
    return c:IsSetCard(0x906) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
function s.extra_filter(c)
    return c:IsFaceup() and c:IsSetCard(0x906) and c:IsType(TYPE_EXTRA)
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.extra_filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Recover(tp,500,REASON_EFFECT)
end