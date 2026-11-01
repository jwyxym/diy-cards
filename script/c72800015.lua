-- 名もなき何もかも
-- ID: 72800015
-- 反击陷阱
-- 「TOGENASHI TOGEARI」字段：0xb15
local s,id=GetID()
function s.initial_effect(c)
    -- 盖放的回合也能发动（自己场上有「TOGENASHI TOGEARI」怪兽）
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e0:SetCondition(s.actcon)
    c:RegisterEffect(e0)

    -- ① 对方把怪兽·魔法·陷阱的效果发动时，返回自己场上1只从额外卡组特殊召唤的「TOGENASHI TOGEARI」怪兽，那个发动无效并破坏
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
end

-- 盖放回合可发动的条件：自己场上有「TOGENASHI TOGEARI」怪兽
function s.actcon(e)
    return Duel.IsExistingMatchingCard(s.fieldfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

function s.fieldfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xb15) and c:IsType(TYPE_MONSTER)
end

-- 发动条件：对方发动效果，且自己场上有可返回额外卡组的怪兽
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    if rp==tp then return false end
    if not Duel.IsChainNegatable(ev) then return false end
    return Duel.IsExistingMatchingCard(s.retfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- 可返回额外卡组的怪兽：从额外卡组特殊召唤的「TOGENASHI TOGEARI」怪兽
function s.retfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xb15) and c:IsSummonLocation(LOCATION_EXTRA)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.retfilter,tp,LOCATION_MZONE,0,nil)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOEXTRA)
    local sg=g:Select(tp,1,1,nil)
    if #sg==0 then return end
    if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
        if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
            Duel.Destroy(eg,REASON_EFFECT)
        end
    end
end