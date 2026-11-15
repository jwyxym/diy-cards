-- 鸣动の刻
-- ID: 72800004
-- 场地魔法
-- 「TOGENASHI TOGEARI」字段：0xb15
local s,id=GetID()
function s.initial_effect(c)
    -- 场地魔法的发动
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- ① 自己场上有5种属性的超量怪兽的场合，那些怪兽和场上的这张卡1回合各有1次不会被战斗·效果破坏
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_XYZ))
    e1:SetCountLimit(1)
    e1:SetValue(s.indval)
    e1:SetCondition(s.indcon)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e2:SetCountLimit(1)
    e2:SetValue(s.indval)
    e2:SetCondition(s.indcon)
    c:RegisterEffect(e2)

    -- ② 以自己场上1只「TOGENASHI TOGEARI」怪兽为对象，宣言「TOGENASHI TOGEARI」才能发动
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_FZONE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetTarget(s.xyztg)
    e3:SetOperation(s.xyzop)
    c:RegisterEffect(e3)
end

-- ① 条件：自己场上有5种属性不同的超量怪兽
function s.indcon(e)
    local tp=e:GetHandlerPlayer()
    local g=Duel.GetMatchingGroup(aux.FilterBoolFunction(Card.IsType,TYPE_XYZ),tp,LOCATION_MZONE,0,nil)
    if #g<5 then return false end
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
    return cnt>=5
end
function s.indval(e,re,r,rp)
    return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end

-- ② 对象：自己场上1只「TOGENASHI TOGEARI」怪兽
function s.tgfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xb15) and c:IsType(TYPE_MONSTER)
end

-- ② 额外卡组过滤：同属性、可特殊召唤的「TOGENASHI TOGEARI」超量怪兽
-- 移除 GetLocationCountFromEx 与 IsCanBeXyzMaterial 的兼容性调用，防止参数报错
function s.xyzfilter(c,e,tp,attr)
    return c:IsSetCard(0xb15) and c:IsType(TYPE_XYZ)
        and c:IsAttribute(attr)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end

-- ② 目标
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
    if chk==0 then
        local mg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,0,nil)
        local tc=mg:GetFirst()
        while tc do
            if Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,tc:GetAttribute()) then
                return true
            end
            tc=mg:GetNext()
        end
        return false
    end

    -- 发动前添加两个不影响实际效果的选项
    Duel.SelectYesNo(tp, aux.Stringid(id,1))

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- ② 操作：在素材怪兽原本所在的格子上叠放超量召唤
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
    local attr=tc:GetAttribute()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,attr)
    local sc=g:GetFirst()
    if not sc then return end

    -- 将 tc 原有的超量素材转移给 sc（如果 tc 本身也是超量怪兽）
    local mg=tc:GetOverlayGroup()
    if mg and mg:GetCount()>0 then
        Duel.Overlay(sc,mg)
    end

    -- 将 tc 作为素材叠放到 sc 下方
    sc:SetMaterial(Group.FromCards(tc))
    Duel.Overlay(sc,Group.FromCards(tc))

    -- 在 tc 原本所在的格子上特殊召唤 sc
    Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
    sc:CompleteProcedure()
end