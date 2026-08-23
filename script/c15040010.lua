-- 异响鸣之神选-誓拉尔梅
-- ID: 25040010
-- 字段：异响鸣 (0x1a3)
local s,id=GetID()
function s.initial_effect(c)
    -- ① 展示自身与额外卡组1只天使族·暗属性怪兽，检索「异响鸣」灵摆怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- ② 召唤·灵摆召唤成功时，回复500，从卡组送墓1只「异响鸣」怪兽
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_RECOVER+CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+1)
    e2:SetTarget(s.rettg)
    e2:SetOperation(s.retop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCondition(s.spcon2)  -- 检查是否为灵摆召唤
    c:RegisterEffect(e3)
end

-- ① 发动条件：自己场上没有怪兽或有「异响鸣」卡存在
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local b1 = Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
    local b2 = Duel.IsExistingMatchingCard(aux.FilterBoolFunction(Card.IsSetCard,0x1a3),tp,LOCATION_ONFIELD,0,1,nil)
    return b1 or b2
end

-- ① cost：展示额外卡组1只天使族·暗属性怪兽和手牌此卡
function s.extra_filter(c)
    return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_MONSTER)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.extra_filter,tp,LOCATION_EXTRA,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.extra_filter,tp,LOCATION_EXTRA,0,1,1,nil)
    local rg=Group.FromCards(c,g:GetFirst())
    Duel.ConfirmCards(1-tp,rg)
end

-- ① 检索过滤：「异响鸣」灵摆怪兽
function s.thfilter(c)
    return c:IsSetCard(0x1a3) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- ② 条件（灵摆召唤的特殊召唤）
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end

-- ② 送墓过滤：「异响鸣」怪兽
function s.tgfilter(c)
    return c:IsSetCard(0x1a3) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Recover(tp,500,REASON_EFFECT)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end