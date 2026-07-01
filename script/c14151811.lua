-- 极星宝 至高王座
function c14151811.initial_effect(c)
    -- ==================== ①效果 ====================
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(14151811, 0))  -- DEX文本行0
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, 14151811)
    e1:SetTarget(c14151811.target)
    e1:SetOperation(c14151811.operation)
    c:RegisterEffect(e1)

    -- ==================== ②效果 ====================
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(14151811, 1))  -- DEX文本行1
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1, 14151812)
    e2:SetCost(c14151811.cost)
    e2:SetTarget(c14151811.sptarget)
    e2:SetOperation(c14151811.spoperation)
    c:RegisterEffect(e2)
end

-- ==================== ①效果：检索条件 ====================
function c14151811.filter(c)
    return c:IsSetCard(0x5042) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end

-- ==================== ①效果：发动时的目标判断（允许空发） ====================
function c14151811.target(e, tp, eg, ep, ev, re, r, rp, chk)
    -- 关键：始终返回 true，允许空发
    if chk == 0 then return true end
    -- 仅当存在可检索卡时才标记操作信息（用于UI预览）
    if Duel.IsExistingMatchingCard(c14151811.filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) then
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
    end
end

-- ==================== ①效果：效果处理（带选项框，允许空发） ====================
function c14151811.operation(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(c14151811.filter), tp, LOCATION_DECK + LOCATION_GRAVE, 0, nil)
    
    -- 如果没有可检索的卡，直接结束，不弹窗
    if g:GetCount() == 0 then
        return
    end
    
    -- 有可检索的卡时，弹窗询问（DEX文本行2）
    if Duel.SelectYesNo(tp, aux.Stringid(14151811, 2)) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local sg = g:Select(tp, 1, 1, nil)
        if sg:GetCount() > 0 then
            Duel.SendtoHand(sg, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, sg)
        end
    end
    -- 如果玩家选择“否”，什么都不做，卡片留在场上
end

-- ==================== ②效果：代价 ====================
function c14151811.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, nil) end
    Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
    local g = Duel.SelectMatchingCard(tp, Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, 1, nil)
    Duel.SendtoGrave(g, REASON_COST + REASON_DISCARD)
end

-- ==================== ②效果：特召条件 ====================
function c14151811.spfilter(c, e, tp)
    return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

-- ==================== ②效果：发动时的目标判断 ====================
function c14151811.sptarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and Duel.IsExistingMatchingCard(c14151811.spfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

-- ==================== ②效果：效果处理 ====================
function c14151811.spoperation(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, c14151811.spfilter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
    if #g > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
    end
end