-- 十二星天·莉布拉
-- id: 71000278
-- setcode: 0x3e14

local s, id = GetID()
local SET_ZODIAC = 0x3e14

function s.initial_effect(c)
    -- ①：1回合1次，自己场上没有「十二星天」怪兽存在的场合，这张卡可以从手卡特殊召唤。或者把自己场上1只「十二星天」怪兽解放，这张卡可以从手卡特殊召唤。这个效果特殊召唤成功后，直到回合结束时自己不是12星怪兽不能从手卡特殊召唤。
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- ②：这张卡向对方怪兽攻击宣言时才能发动。那只怪兽破坏。这个效果发动后，这张卡不能攻击。
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

-- 「十二星天」怪兽过滤器
function s.zfilter(c)
    return c:IsSetCard(SET_ZODIAC) and c:IsType(TYPE_MONSTER)
end

-- ========== ① 特召条件 ==========
function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    -- 必须有格子
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return false end
    
    -- 情况A：场上没有「十二星天」，无条件特召
    if not Duel.IsExistingMatchingCard(s.zfilter, tp, LOCATION_MZONE, 0, 1, nil) then
        return true
    end
    -- 情况B：场上有「十二星天」，则需要有能解放的怪
    return Duel.CheckReleaseGroup(tp, s.zfilter, 1, nil)
end

-- ========== ① 特召目标 ==========
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, c)
    if chk == 0 then return true end
    -- 如果场上有「十二星天」，则进行解放选择
    local g = Duel.GetReleaseGroup(tp):Filter(s.zfilter, nil)
    if g:GetCount() > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
        local sg = g:Select(tp, 1, 1, nil)
        if sg:GetCount() > 0 then
            sg:KeepAlive()
            e:SetLabelObject(sg)
            return true
        end
        return false
    end
    return true
end

-- ========== ① 特召操作 ==========
function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    -- 执行解放代价
    local sg = e:GetLabelObject()
    if sg then
        Duel.Release(sg, REASON_COST)
        sg:DeleteGroup()
    end
    
    -- 【新增】特召成功后，赋予手卡特召自肃：直到回合结束，自己不是12星怪兽不能从手卡特殊召唤。
    local e_restrict = Effect.CreateEffect(c)
    e_restrict:SetType(EFFECT_TYPE_FIELD)
    e_restrict:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e_restrict:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e_restrict:SetTargetRange(1, 0)
    e_restrict:SetTarget(s.splimit)
    e_restrict:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(e_restrict, tp)
end

-- 自肃过滤器：限制手卡非12星特召
function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
    if c:IsLocation(LOCATION_HAND) then
        return not c:IsLevel(12)
    end
    return false
end

-- ========== ② 攻击宣言破坏 ==========
-- 触发条件
function s.descon(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetAttackTarget()
    return tc ~= nil and tc:IsControler(1 - tp) and tc:IsType(TYPE_MONSTER)
end

-- 目标处理
function s.destg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        local tc = Duel.GetAttackTarget()
        return tc and tc:IsDestructable()
    end
    local tc = Duel.GetAttackTarget()
    Duel.SetTargetCard(tc)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, tc, 1, 1 - tp, LOCATION_MZONE)
end

-- 操作处理
function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    
    -- 执行破坏
    if tc and tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) then
        Duel.Destroy(tc, REASON_EFFECT)
    end
    
    -- 限制这张卡不能攻击
    if c:IsRelateToEffect(e) then
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_ATTACK)
        e1:SetProperty(EFFECT_FLAG_OATH)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        c:RegisterEffect(e1)
    end
end