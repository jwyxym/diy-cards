-- 穚镰鸦姬 翼厄截止
-- ID: 26052054
-- 字段：穚镰鸦姬 0x914
local s,id=GetID()

function s.initial_effect(c)
    -- 显式声明类型：反击陷阱
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_TYPE)
    e0:SetValue(TYPE_TRAP+TYPE_COUNTER)
    c:RegisterEffect(e0)

    -- ① 自己场上有本家怪兽，对方怪兽效果发动时，无效并破坏
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetRange(LOCATION_SZONE)       -- 保险：限制在魔陷区
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)

    -- ② 双方主要阶段，墓地除外这张卡，进行1只本家怪兽的上级召唤
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.advcon)
    e2:SetCost(s.advcost)
    e2:SetTarget(s.advtg)
    e2:SetOperation(s.advop)
    c:RegisterEffect(e2)
end

-- ①
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    if rp==tp then return false end
    if not re:IsActiveType(TYPE_MONSTER) then return false end
    if not Duel.IsChainNegatable(ev) then return false end
    return Duel.IsExistingMatchingCard(function(c)
        return c:IsFaceup() and c:IsSetCard(0x914) and c:IsType(TYPE_MONSTER)
    end,tp,LOCATION_MZONE,0,1,nil)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end

-- ②
function s.advcon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
function s.advcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.advtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(function(c)
        return c:IsSummonable(true,nil) and c:IsLevelAbove(5) and c:IsSetCard(0x914)
    end,tp,LOCATION_HAND,0,1,nil) end
end
function s.advop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(function(c)
        return c:IsSummonable(true,nil) and c:IsLevelAbove(5) and c:IsSetCard(0x914)
    end,tp,LOCATION_HAND,0,nil)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
    local tc=g:Select(tp,1,1,nil):GetFirst()
    if not tc then return end
    Duel.Summon(tp,tc,true,nil)
end