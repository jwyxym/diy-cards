-- 女神的魔法·艾克斯之门
-- id: 71000254
-- setcode: 0x3e13

local cm, m, o = GetID()

function cm.initial_effect(c)
    -- 【全局监测：只记录自己是否违规特召】
    if not cm.global_check then
        cm.global_check = true
        local ge1 = Effect.GlobalEffect()
        ge1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
        ge1:SetOperation(cm.checkop)
        Duel.RegisterEffect(ge1, 0)
    end

    -- ①：作为这张卡的发动时的效果处理，从卡组把1只12星怪兽加入手卡。
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(m, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, m)
    e1:SetCondition(cm.con1) -- 【新增】如果自己本回合已经违规特召过，就不能发动
    e1:SetTarget(cm.tg1)
    e1:SetOperation(cm.op1)
    c:RegisterEffect(e1)

    -- ②：自己墓地·场上没有「露法丝·玛法尔」怪兽存在的场合才能发动。
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(m, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1, m + 1)
    e2:SetCondition(cm.con2)
    e2:SetTarget(cm.tg2)
    e2:SetOperation(cm.op2)
    c:RegisterEffect(e2)
end

-- 【全局监测逻辑】只监测是否进行了违规特召
function cm.checkop(e, tp, eg, ep, ev, re, r, rp)
    local c = eg:GetFirst()
    while c do
        -- 如果是从额外卡组特召，且不是 12阶超量怪兽
        if c:IsPreviousLocation(LOCATION_EXTRA) and not (c:IsType(TYPE_XYZ) and c:IsRank(12)) then
            -- 标记该怪兽的控制者（如果是你出的，你就拿到标记；对方出的，标记打在对方身上）
            Duel.RegisterFlagEffect(c:GetControler(), m, RESET_PHASE + PHASE_END, 0, 1)
        end
        c = eg:GetNext()
    end
end

-- 【发动条件】只检查自己（tp）身上有没有标记，没有才能发
function cm.con1(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFlagEffect(tp, m) == 0
end

-- ① 检索过滤器：12星怪兽
function cm.thfilter(c)
    return c:IsLevel(12) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(cm.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
    -- 【发动后的誓约】立刻生效，封锁自己后续的非12阶特召
    local e_restrict = Effect.CreateEffect(e:GetHandler())
    e_restrict:SetType(EFFECT_TYPE_FIELD)
    e_restrict:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e_restrict:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e_restrict:SetTargetRange(1, 0) -- 只限制自己
    e_restrict:SetTarget(cm.splimit)
    e_restrict:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(e_restrict, tp)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, cm.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
        Duel.ShuffleHand(tp)
    end
end

-- 誓约过滤器：只允许12阶超量
function cm.splimit(e, c, sump, sumtype, sumpos, targetp, se)
    if c:IsLocation(LOCATION_EXTRA) then
        return not (c:IsType(TYPE_XYZ) and c:IsRank(12))
    end
    return false
end

-- ② 条件
function cm.con2(e, tp, eg, ep, ev, re, r, rp)
    return not Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, 1, nil, 71000242)
end

-- ② 选卡
function cm.spfilter(c, e, tp)
    return c:IsCode(71000242) and not c:IsType(TYPE_XYZ)
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and Duel.IsExistingMatchingCard(cm.spfilter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_DECK)
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, cm.spfilter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil, e, tp)
    if #g > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, true, false, POS_FACEUP)
    end
end