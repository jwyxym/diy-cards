-- 暗夜织者的吧台助手 小八
-- ID: 26052012
-- 字段：暗夜织者 0x912
local s,id=GetID()
function s.initial_effect(c)
    -- ① 召唤·特召时，从卡组堆1张「暗夜织者」卡（排除自身）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)
    local e1b=e1:Clone()
    e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1b)

    -- ② 被送去墓地时，从卡组检索1只昆虫族仪式怪兽
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1,id+1000)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
end

-- ① 过滤：本家卡，排除自身
function s.tgfilter(c)
    return c:IsSetCard(0x912) and c:IsAbleToGrave() and not c:IsCode(id)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end

    -- ① 誓约：直到下个回合结束时，自己不是昆虫族怪兽不能特殊召唤
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit1)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
end
function s.splimit1(e,c)
    return not c:IsRace(RACE_INSECT)
end

-- ②
function s.thfilter(c)
    return c:IsRace(RACE_INSECT) and c:IsType(TYPE_RITUAL)
        and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end

    -- ② 誓约：直到回合结束时，自己不能把「暗夜织者」仪式怪兽以外的仪式怪兽特殊召唤
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetDescription(aux.Stringid(id,3))
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit2)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.splimit2(e,c)
    return c:IsType(TYPE_RITUAL) and not c:IsSetCard(0x912)
end