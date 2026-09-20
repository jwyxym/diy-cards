-- 跃音萌行 星途启奏
-- ID: 26051983
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
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
end
function s.filter1(c)
    return (c:IsSetCard(0x906) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)))
        or (c:IsRace(RACE_CYBERSE) and c:IsLevelBelow(4) and c:IsType(TYPE_MONSTER))
end
function s.filter2(c)
    return c:IsSetCard(0x906) and c:IsType(TYPE_MONSTER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    local b1=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil)
        and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    elseif not b1 then
        op=1
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    if op==0 then
        local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    else
        local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
    -- 自肃
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.sumlimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(1,0)
    e2:SetTarget(s.sumlimit)
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2,tp)
end
function s.sumlimit(e,c)
    return not c:IsSetCard(0x906)
end