-- 逆时残响 玫瑰特派
-- ID: 26051998
-- 字段：逆时残响 0x910
-- 反击陷阱
local s,id=GetID()
function s.initial_effect(c)
    -- ① 反击陷阱
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.negcon)
    e1:SetCost(s.negcost)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)

    -- ② 墓地除外回收
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_HANDES)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCost(s.rec2cost)
    e2:SetTarget(s.rec2tg)
    e2:SetOperation(s.rec2op)
    c:RegisterEffect(e2)
end

-- 自定义过滤：表侧本家
function s.faceup_honka(c)
    return c:IsFaceup() and c:IsSetCard(0x910)
end

-- ① 条件：对方发动效果，且自己场上有本家
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp
        and Duel.IsExistingMatchingCard(s.faceup_honka,tp,LOCATION_MZONE,0,1,nil)
end
-- ① cost：解放自己场上1只魔法师族怪兽（基础API）
function s.relfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsReleasable()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectMatchingCard(tp,s.relfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Release(g,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        local rc=re:GetHandler()
        if rc and rc:IsRelateToEffect(re) and rc:IsDestructable() then
            Duel.Destroy(rc,REASON_EFFECT)
        end
    end
end

-- ② cost：除外自身
function s.rec2cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- ② 目标：墓地6星以下魔法师族
function s.rec2filter(c)
    return c:IsRace(RACE_SPELLCASTER) and c:IsLevelBelow(6) and c:IsAbleToHand()
end
function s.rec2tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rec2filter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.rec2op(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.rec2filter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        if Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) then
            Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD)
        end
    end
end