-- 跃音萌行 协律阵线
-- ID: 26051987
-- 字段：跃音萌行 0x906 / 凛 0x907 / 布若 0x908 / 玛莉嘉 0x909
local s,id=GetID()
function s.initial_effect(c)
    -- 效果A：攻击力上升
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
    e1:SetTarget(s.atktg)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)

    -- 效果B：无效破坏效果
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_NEGATE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.cost)
    e2:SetCondition(s.negcon)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
end
function s.costfilter(c)
    return c:IsFaceup() and (c:IsSetCard(0x907) or c:IsSetCard(0x908) or c:IsSetCard(0x909))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil) end
    local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil)
    e:SetLabel(g:GetFirst():GetBaseAttack())
    Duel.Release(g,REASON_COST)
end

-- 效果A 目标/操作
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.costfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.costfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(e:GetLabel())
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
    end
end

-- 效果B 条件/操作
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and Duel.IsChainDisablable(ev)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateEffect(ev)
end