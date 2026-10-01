-- 逆时残响 梁月
-- ID: 26052004
-- 字段：逆时残响 0x910 / 升阶 0x911
local s,id=GetID()
function s.initial_effect(c)
    aux.AddSynchroProcedure(c, s.tunfilter, aux.NonTuner(nil), 1)
    c:EnableReviveLimit()

    local e0b=Effect.CreateEffect(c)
    e0b:SetType(EFFECT_TYPE_SINGLE)
    e0b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0b:SetCode(EFFECT_ADD_SETCODE)
    e0b:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
    e0b:SetValue(0x911)
    c:RegisterEffect(e0b)

    -- ① 同调召唤时，破坏对方全部怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.descon)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    -- ② 可对对方怪兽各攻击1次
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_ATTACK_ALL)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- ③ 对方魔陷发动时，丢弃1手卡无效并破坏
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+1000)
    e3:SetCondition(s.negcon)
    e3:SetCost(s.negcost)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
end

function s.tunfilter(c)
    return c:IsSetCard(0x910) and c:IsType(TYPE_TUNER)
end

-- ①
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil) end
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
    if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
end

-- ③
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        local rc=re:GetHandler()
        if rc and rc:IsRelateToEffect(re) and rc:IsDestructable() then
            Duel.Destroy(rc,REASON_EFFECT)
        end
    end
end