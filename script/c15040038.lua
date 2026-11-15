-- 以太的「ELEMENTS」
-- ID: 15040038
-- 卡类型：请设置为永续魔法或永续陷阱
-- 「赞颂音乐的人偶」(15040037) 卡名记述
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,15040037)  -- 此卡记述「赞颂音乐的人偶」

    -- 卡的发动
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- ① 自己场上只能有1张表侧表示存在
    c:SetUniqueOnField(1,0,id)

    -- ② 场上的超量素材被取除的场合，自己场上记述「赞颂音乐的人偶」的怪兽攻击力上升300
    -- 改为监听多个离场事件
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_TO_GRAVE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCondition(s.atkcon)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)
    local e1b=e1:Clone()
    e1b:SetCode(EVENT_REMOVE)
    c:RegisterEffect(e1b)
    local e1c=e1:Clone()
    e1c:SetCode(EVENT_TO_HAND)
    c:RegisterEffect(e1c)
    local e1d=e1:Clone()
    e1d:SetCode(EVENT_TO_DECK)
    c:RegisterEffect(e1d)

    -- ③ 1回合1次，双方主要阶段：取除场上1个超量素材，然后可选1只怪兽ATK-300、效果无效
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.ovcost)
    e2:SetTarget(s.distg)
    e2:SetOperation(s.disop)
    c:RegisterEffect(e2)
end

-- ② 条件：事件中的卡有原本位于超量素材区的
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c) return c:IsPreviousLocation(LOCATION_OVERLAY) end,1,nil)
end

-- ② 操作：自己场上记述「赞颂音乐的人偶」的怪兽ATK+300（永久）
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
    if #g==0 then return end
    local tc=g:GetFirst()
    while tc do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(300)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        tc=g:GetNext()
    end
end
function s.atkfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,15040037)
end

-- ③ cost：取除场上1个超量素材
function s.ovfilter(c)
    return c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
function s.ovcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectMatchingCard(tp,s.ovfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        tc:RemoveOverlayCard(tp,1,1,REASON_COST)
    end
end

-- ③ 目标（可选）
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

-- ③ 操作：可选1只怪兽ATK-300、效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then return end
    if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    local tc=g:GetFirst()
    if not tc then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(-300)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_DISABLE)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e2)
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_DISABLE_EFFECT)
    e3:SetValue(RESET_TURN_SET)
    e3:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e3)
end