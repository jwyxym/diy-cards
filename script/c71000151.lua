--石之世界王国的斯坦利
-- 卡片类型：怪兽卡, 同调, 效果
-- 地 7星 战士族 2800/2000
-- 同调素材：调整 + 调整以外的「石之世界」怪兽1只以上
local cm, m, o = GetID()

-- 【核心修复】完全自定义调整与非调整过滤函数，彻底绕开 aux 工具函数在 mdPro3 的报错
function cm.tuner_filter(c)
	return c:IsType(TYPE_TUNER)
end

function cm.nontuner_filter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TUNER) and c:IsSetCard(0x3e12)
end

function cm.initial_effect(c)
	-- 同调召唤条件
	c:EnableReviveLimit()
	-- 要求：1只调整 + 1只以上调整以外的「石之世界」怪兽
	aux.AddSynchroProcedure(c, cm.tuner_filter, cm.nontuner_filter, 1, 99)

	-- ①：卡的效果发动的场合才能发动。选对方场上1张卡里侧表示除外。那之后，这张卡变成里侧守备表示。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_REMOVE + CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1, m)
	e1:SetCondition(cm.con1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡在墓地存在的场合，自己场上有「石之世界的杰诺」的场合才能发动。这张卡从墓地里侧守备特殊召唤。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1, m + 1)
	e2:SetCondition(cm.con2)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

-- ① 条件：自身需为表侧表示
function cm.con1(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():IsFaceup()
end

-- ① 目标：选择对方场上1张卡
function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1 - tp) end
	if chk == 0 then
		return Duel.IsExistingTarget(nil, tp, 0, LOCATION_ONFIELD, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local g = Duel.SelectTarget(tp, nil, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, 0, 0)
end

-- ① 操作：里侧除外 → 自身变里侧守备
function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local tc = Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Remove(tc, POS_FACEDOWN, REASON_EFFECT)
	end
	-- 那之后，这张卡变成里侧守备表示
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() then
		Duel.ChangePosition(c, POS_FACEDOWN_DEFENSE)
	end
end

-- ② 条件：自己场上有「石之世界的杰诺」(71000145)表侧表示存在
function cm.con2(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_MZONE, 0, 1, nil, 71000145)
end

-- ② 目标
function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

-- ② 操作：从墓地里侧守备特召
function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEDOWN_DEFENSE)
	end
end