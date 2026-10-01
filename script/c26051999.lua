-- 逆时残响 "大团圆"
-- ID: 26051999
-- 字段：逆时残响 0x910
-- 永续陷阱
local s,id=GetID()
function s.initial_effect(c)
    -- 作为永续陷阱发动
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- ① 本家各有1次不会被效果破坏
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(s.indtg)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- ② 双方回合，无效对方场上1张表侧卡
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.discon)
    e2:SetTarget(s.distg)
    e2:SetOperation(s.disop)
    c:RegisterEffect(e2)
end

-- ① 破坏耐性
function s.indtg(e,c)
    return c:IsSetCard(0x910)
end

-- ② 条件：自己场上有从额外卡组特召的本家
function s.exfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x910)
        and c:IsSummonType(SUMMON_TYPE_SPECIAL)
        and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- 目标过滤：对方场上的表侧卡
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsFaceup() and tc:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(e2)
    end
end