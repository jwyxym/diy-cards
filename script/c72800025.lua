-- NINA！！！
-- ID: 72800025
-- 融合怪兽
-- 素材：「Iseri Nina」(72800000) + 「GIRLS BAND CRY」(72800002)
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddFusionProcCode2(c,72800000,72800002,true,true)
    aux.AddCodeList(c,72800000,72800002)
    aux.AddMaterialCodeList(c,72800000)
    aux.AddMaterialCodeList(c,72800002)

    -- 只能用融合召唤特殊召唤
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(aux.fuslimit)
    c:RegisterEffect(e0)

    -- ① 只要场地区域有卡存在，这张卡不会被效果破坏
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetCondition(s.indcon)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- ② 自己场上怪兽属性3种以上，对方在场上发动效果时，无效并破坏
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.negcon)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
end

-- ① 条件：场地区域有卡
function s.indcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.GetFieldGroupCount(tp,LOCATION_FZONE,LOCATION_FZONE)>0
end

-- ② 条件：对方在场上发动效果，且自己场上怪兽属性3种以上
function s.attrcon(tp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    local attrs={}
    local cnt=0
    local tc=g:GetFirst()
    while tc do
        local a=tc:GetAttribute()
        if a and a>0 and not attrs[a] then
            attrs[a]=true
            cnt=cnt+1
        end
        tc=g:GetNext()
    end
    return cnt>=3
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    if rp==tp then return false end
    if not re then return false end
    local rc=re:GetHandler()
    if not rc or not rc:IsLocation(LOCATION_ONFIELD) then return false end
    if not Duel.IsChainNegatable(ev) then return false end
    return s.attrcon(tp)
end

-- ② 目标
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end

-- ② 操作：无效并破坏
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end