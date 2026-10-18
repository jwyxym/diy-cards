--石之世界的大木大树
-- 卡片类型：怪兽卡, 效果
-- 地 6星 战士族 2300/2000
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：自己场上有「石之世界的石神千空」存在的场合才能发动。这张卡从手卡里侧守备表示特殊召唤。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1, m)
	e1:SetCondition(cm.con1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡变成表侧表示的场合才能发动。从自己卡组·墓地选1张「石之世界的小川杠」加入手卡，自己场上有「石之世界的石神千空」存在的场合，也能不加入手卡里侧守备表示特殊召唤。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_FLIP)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1, m + 1)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)

	-- ③：只要这张卡在自己场上表侧表示存在，自己里侧守备表示的怪兽不会被对方的效果破坏。
	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cm.con3)
	e3:SetTargetRange(LOCATION_MZONE, 0) -- 影响自己场上的怪兽
	e3:SetTarget(cm.tg3)                 -- 指定里侧守备表示的怪兽
	e3:SetValue(cm.val3)                 -- 指定只对“对方的效果破坏”生效
	c:RegisterEffect(e3)
end

-- ========== ① ==========
-- ① 条件：自己场上有表侧表示的「石之世界的石神千空」(71000120)
function cm.con1(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsExistingMatchingCard(cm.filter1, tp, LOCATION_MZONE, 0, 1, nil)
end
function cm.filter1(c) return c:IsCode(71000120) and c:IsFaceup() end
function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsExistingMatchingCard(cm.filter1, tp, LOCATION_MZONE, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, tp, LOCATION_HAND)
end
function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEDOWN_DEFENSE)
end

-- ========== ② ==========
-- ② 目标：卡组·墓地有「石之世界的小川杠」(71000138)
function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(cm.thfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function cm.thfilter(c)
	return c:IsCode(71000138) and c:IsAbleToHand()
end

-- ② 操作：检索或特召「石之世界的小川杠」
function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, cm.thfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
	if #g == 0 then return end
	local tc = g:GetFirst()

	local hasSenku = Duel.IsExistingMatchingCard(cm.filter1, tp, LOCATION_MZONE, 0, 1, nil)
	if hasSenku and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 
		and Duel.SelectYesNo(tp, aux.Stringid(m, 2)) then
		-- 选择里侧守备特殊召唤
		Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEDOWN_DEFENSE)
	else
		-- 加入手卡
		Duel.SendtoHand(tc, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, tc)
	end
end

-- ========== ③ ==========
-- 条件：这张卡自己表侧表示在场上
function cm.con3(e)
	return e:GetHandler():IsFaceup()
end

-- 过滤：自己场上里侧守备表示的怪兽
function cm.tg3(e, c)
	return c:IsFacedown() and c:IsDefensePos()
end

-- 限制：只有对方的效果破坏才能被免疫
function cm.val3(e, re, r, rp)
	-- 如果效果发动者是对手，则免疫生效
	return rp == 1 - e:GetHandlerPlayer()
end