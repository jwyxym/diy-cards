--石之世界的小川杠
-- 卡片类型：怪兽卡, 效果, 调整
-- 地 4星 魔法师族 500/1500
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：把手卡1张「石之世界的复活药剂」给对方观看才能发动。从卡组选1只「石之世界」怪兽里侧守备表示特殊召唤。那之后，这张卡变成里侧守备表示。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1, m)
	e1:SetCost(cm.cost1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡变成表侧表示的场合才能发动，从墓地把1只「石之世界」怪兽里侧守备表示特殊召唤，把1张「石之世界的复活药剂」从卡组·墓地加入手卡。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOHAND + CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_FLIP)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1, m + 1)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

-- ========== ① ==========
-- ① 代价：展示手卡1张「石之世界的复活药剂」
function cm.cost1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_HAND, 0, 1, nil, 71000126)
	end
	local g = Duel.SelectMatchingCard(tp, Card.IsCode, tp, LOCATION_HAND, 0, 1, 1, nil, 71000126)
	if #g > 0 then
		Duel.ConfirmCards(1 - tp, g)
	end
end

-- ① 卡组特召过滤
function cm.spfilter1(c, e, tp)
	return c:IsSetCard(0x3e12) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

-- ① 目标
function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
			and e:GetHandler():IsFaceup()
			and Duel.IsExistingMatchingCard(cm.spfilter1, tp, LOCATION_DECK, 0, 1, nil, e, tp)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

-- ① 操作：卡组特召 → 自身变成里侧守备
function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, cm.spfilter1, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
	if #g > 0 then
		Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEDOWN_DEFENSE)
	end
	-- 那之后，这张卡变成里侧守备表示
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() then
		Duel.ChangePosition(c, POS_FACEDOWN_DEFENSE)
	end
end

-- ========== ② ==========
-- ② 墓地特召过滤
function cm.spfilter2(c, e, tp)
	return c:IsSetCard(0x3e12) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

-- ② 检索过滤
function cm.thfilter(c)
	return c:IsCode(71000126) and c:IsAbleToHand()
end

-- ② 目标
function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
			and Duel.IsExistingMatchingCard(cm.spfilter2, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)
			and Duel.IsExistingMatchingCard(cm.thfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

-- ② 操作：墓地特召 → 检索/回收复活药剂
function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	-- 1. 从墓地特召
	if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local g = Duel.SelectMatchingCard(tp, cm.spfilter2, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
		if #g > 0 then
			Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEDOWN_DEFENSE)
		end
	end
	-- 2. 检索或回收「石之世界的复活药剂」
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local sg = Duel.SelectMatchingCard(tp, cm.thfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
	if #sg > 0 then
		Duel.SendtoHand(sg, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, sg)
		Duel.ShuffleHand(tp)
	end
end