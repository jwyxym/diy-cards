--石之世界的石神千空
-- 卡片类型：怪兽卡, 效果
-- 地 1星 魔法师族 100/100
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组·墓地选1张「石之世界的复活药剂」卡加入手卡。那之后，这张卡变成里侧守备表示。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1, m)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)
	local e1b = e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)

	-- ②：这张卡变成表侧表示的场合才能发动，从卡组·墓地选1张「石之世界」卡加入手卡。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_FLIP)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1, m + 1)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)

	-- ③：只要自己场上有这张卡以外的表侧表示「石之世界」怪兽存在，这张卡不会成为对方的攻击对象，也不会成为对方的效果对象。
	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cm.con3)
	e3:SetValue(aux.imval1)
	c:RegisterEffect(e3)
	local e4 = Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(cm.con3)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
end

-- ① 目标：卡组·墓地有「石之世界的复活药剂」
function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(cm.thfilter1, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

-- ① 操作：检索 → 变成里侧守备表示
function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, cm.thfilter1, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, g)
		Duel.ShuffleHand(tp)
	end
	-- 那之后，这张卡变成里侧守备表示
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) then
		Duel.ChangePosition(c, POS_FACEDOWN_DEFENSE)
	end
end

-- 「石之世界的复活药剂」过滤
function cm.thfilter1(c)
	return c:IsCode(71000126) and c:IsAbleToHand()
end

-- ② 目标：卡组·墓地有「石之世界」卡
function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(cm.thfilter2, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

-- ② 操作：检索「石之世界」卡
function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, cm.thfilter2, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, g)
		Duel.ShuffleHand(tp)
	end
end

-- 「石之世界」过滤
function cm.thfilter2(c)
	return c:IsSetCard(0x3e12) and c:IsAbleToHand()
end

-- ③ 条件：自己场上存在这张卡以外的表侧表示「石之世界」怪兽
function cm.con3(e)
	local c = e:GetHandler()
	return Duel.IsExistingMatchingCard(cm.filter3, c:GetControler(), LOCATION_MZONE, 0, 1, c)
end

function cm.filter3(c, exclude)
	return c ~= exclude and c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x3e12)
end