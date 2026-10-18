-- 管乐部的相遇
-- ID: 15040018
-- 「千早爱音」字段：0xb12
-- 「转校生 丰川祥子」ID：15040020
local s,id=GetID()
function s.initial_effect(c)
    -- ① 卡的发动
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition1)
    e1:SetCost(s.cost1)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.operation1)
    c:RegisterEffect(e1)

    -- ② 被「千早爱音」卡的效果从手卡送去墓地时发动
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.discardcon)
    e2:SetTarget(s.returntg)
    e2:SetOperation(s.returnop)
    c:RegisterEffect(e2)

    -- ② 被「千早爱音」卡的效果从手卡除外时发动
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_REMOVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id+1)
    e3:SetCondition(s.removecon)
    e3:SetTarget(s.returntg)
    e3:SetOperation(s.returnop)
    c:RegisterEffect(e3)
end

-- ① 条件：自己场上没有怪兽，或自己场上有「千早爱音」怪兽
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 then return true end
    return Duel.IsExistingMatchingCard(aux.FilterBoolFunction(Card.IsSetCard,0xb12),tp,LOCATION_MZONE,0,1,nil)
end

-- ① 费用：丢弃1张手卡
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

-- ① 过滤：「千早爱音」卡 或 具体的「转校生 丰川祥子」(15040020)
function s.filter1(c)
    return c:IsSetCard(0xb12) or c:IsCode(15040020)
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- ② 条件检查：效果来源必须是「千早爱音」卡
function s.reasoncheck(re,rp)
    if not re then return false end
    local rc=re:GetHandler()
    return rc and rc:IsSetCard(0xb12)
end

-- ② 从手卡被「千早爱音」卡的效果送去墓地时触发
function s.discardcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsPreviousLocation(LOCATION_HAND) then return false end
    if c:GetReasonPlayer()~=tp then return false end
    return s.reasoncheck(re,rp)
end

-- ② 从手卡被「千早爱音」卡的效果除外时触发
function s.removecon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsPreviousLocation(LOCATION_HAND) then return false end
    return s.reasoncheck(re,rp)
end

-- ② 共同目标
function s.returntg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

-- ② 共同操作：从墓地或除外区加入手卡
function s.returnop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED)) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
    end
end