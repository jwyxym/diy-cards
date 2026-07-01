-- 极星将 提尔（动画）lua
--效果1：自己场上没有「极神」怪兽或者幻神兽族怪兽表侧表示存在的场合，这张卡破坏。
--效果2：把这张卡解放才能发动，这个回合幻神兽族怪兽的效果不会被无效化。这个效果在对方的回合也能发动。
local s,id=GetID()
function s.initial_effect(c)
    -- 效果1：自毁效果
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_SELF_DESTROY)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.descon)
    c:RegisterEffect(e1)
    
    -- 效果2：解放自身，保护极神和幻神兽族效果不被无效
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.cost)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

-- 极神卡名集合（根据实际卡片补充）
local norse_gods={
    67098114, -- 极神皇 托尔
    30604579, -- 极神皇 洛基
    93483212, -- 极神圣帝 奥丁
    14151796,
    14151797,
    14151798,
}

function s.descon(e)
    local tp=e:GetHandlerPlayer()
    -- 检查是否有幻神兽族怪兽
    if Duel.IsExistingMatchingCard(s.divine_filter,tp,LOCATION_MZONE,0,1,nil) then
        return false
    end
    -- 检查是否有极神怪兽
    if Duel.IsExistingMatchingCard(s.norse_filter,tp,LOCATION_MZONE,0,1,nil) then
        return false
    end
    return true
end

function s.divine_filter(c)
    return c:IsFaceup() and c:IsRace(RACE_DIVINE)
end

function s.norse_filter(c)
    if not c:IsFaceup() then return false end
    for _,code in ipairs(norse_gods) do
        if c:IsCode(code) then return true end
    end
    return false
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- 创建一个效果，使极神和幻神兽族怪兽的效果不会被无效化
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_DISABLE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(s.target)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

function s.target(e,c)
    -- 幻神兽族
    if c:IsRace(RACE_DIVINE) then return true end
    -- 极神怪兽
    for _,code in ipairs(norse_gods) do
        if c:IsCode(code) then return true end
    end
    return false
end