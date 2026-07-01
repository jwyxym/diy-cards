-- 极星宝 财富魔戒
local s, id, o = GetID()

function s.initial_effect(c)
    aux.AddCodeList(c, 14151812)
    
    -- 永续陷阱基本发动
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    
    -- ==================== ①效果 ====================
    -- 展示手上的「极星」卡，从卡组·墓地检索「极星」卡
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    
    -- ==================== ②效果 ====================
    -- 被对方效果破坏时，场上有极神则抽2
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1, id + o)
    e2:SetCondition(s.drawcon)
    e2:SetTarget(s.drawtg)
    e2:SetOperation(s.drawop)
    c:RegisterEffect(e2)
end

-- ==================== ①效果：条件（主要阶段） ====================
function s.condition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentPhase() == PHASE_MAIN1 or Duel.GetCurrentPhase() == PHASE_MAIN2
end

-- ==================== ①效果：展示代价 ====================
function s.costfilter(c)
    return c:IsSetCard(0x42) and not c:IsPublic()  -- 极星字段 0x42，且未公开
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.costfilter, tp, LOCATION_HAND, 0, 1, nil)
    end
    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    local g = Duel.SelectMatchingCard(tp, s.costfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
    Duel.ConfirmCards(1 - tp, g)  -- 展示给对方
    Duel.ShuffleHand(tp)          -- 展示后洗牌
    e:SetLabel(g:GetFirst():GetCode())  -- 记录展示的卡
end

-- ==================== ①效果：检索目标 ====================
function s.thfilter(c)
    return c:IsSetCard(0x42) and c:IsAbleToHand()  -- 极星字段
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

-- ==================== ①效果：效果处理 ====================
function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local code = e:GetLabel()
    if code == 0 then return end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.thfilter), tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

-- ==================== ②效果：条件 ====================
function s.polfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x4b)  -- 极神字段 0x4b
end

function s.drawcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    -- 被对方的效果破坏
    if not c:IsReason(REASON_EFFECT) then return false end
    if not re or not re:GetHandler():IsControler(1 - tp) then return false end
    if c:GetPreviousControler() ~= tp then return false end
    -- 场上有极神怪兽
    return Duel.IsExistingMatchingCard(s.polfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

-- ==================== ②效果：目标 ====================
function s.drawtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 2)
end

-- ==================== ②效果：效果处理 ====================
function s.drawop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Draw(tp, 2, REASON_EFFECT)
end