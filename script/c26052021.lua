-- 暗夜织者的收尾处理
-- ID: 26052021
-- 字段：暗夜织者 0x912
-- 反击陷阱
local s,id=GetID()
function s.initial_effect(c)
    -- ① 反击陷阱：解放昆虫族怪兽，无效并破坏
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

    -- ② 墓地除外，回收墓地的本家卡 + 抽1
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCost(s.recost)
    e2:SetTarget(s.retg)
    e2:SetOperation(s.reop)
    c:RegisterEffect(e2)
end

-- 自定义过滤：表侧本家
function s.faceup_honka(c)
    return c:IsFaceup() and c:IsSetCard(0x912)
end

-- ①
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp
        and Duel.IsExistingMatchingCard(s.faceup_honka,tp,LOCATION_MZONE,0,1,nil)
end
function s.relfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsReleasable()
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

-- ②
function s.recost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.retgfilter(c)
    return c:IsSetCard(0x912) and c:IsAbleToDeck()
end
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.retgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.reop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.retgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,3,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end