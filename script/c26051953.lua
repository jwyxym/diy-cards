-- 无垠轨途 柯娜
-- ID: 26051953
-- 字段: 0x903
local s,id=GetID()
function s.initial_effect(c)
    -- 同调召唤：无垠轨途调整 + 调整以外怪兽1只以上
    aux.AddSynchroProcedure(c, aux.FilterBoolFunction(Card.IsSetCard,0x903), aux.NonTuner(nil), 1)
    c:EnableReviveLimit()

    -- ① 守备表示可攻击，并以守备力进行伤害计算（参考超重天神）
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DEFENSE_ATTACK)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- ② 不受守备力比这张卡低的对方怪兽发动的效果影响
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECTED_BY_EFFECT)
    e2:SetValue(s.immval)
    c:RegisterEffect(e2)

    -- ③ 二速将对方表侧怪兽变为里侧守备，且不能变更表示形式
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_POSITION)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e3:SetTarget(s.postg)
    e3:SetOperation(s.posop)
    c:RegisterEffect(e3)
end

-- ② 免疫对方守备力低于此卡的怪兽效果
function s.immval(e,te)
    local c = e:GetHandler()
    local rc = te:GetHandler()
    if not te:IsActiveType(TYPE_MONSTER) then return false end
    if rc:IsControler(c:GetControler()) then return false end
    return rc:GetDefense() < c:GetDefense()
end

-- ③ 目标：对方场上1只表侧怪兽
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end

-- ③ 操作：变里侧守备并封锁表示形式变更
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() then
        if Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)~=0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
    end
end