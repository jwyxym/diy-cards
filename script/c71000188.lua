--石之世界的狮子王司
-- 卡片类型：怪兽卡, 同调, 效果
-- 地 10星 兽战士族 3000/3000
-- 同调素材：调整 + 调整以外的「石之世界」怪兽1只以上
local cm, m, o = GetID()

function cm.tuner_filter(c)
	return c:IsType(TYPE_TUNER)
end
function cm.nontuner_filter(c)
	return c:IsSetCard(0x3e12) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TUNER)
end

function cm.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c, cm.tuner_filter, cm.nontuner_filter, 1, 99)

	-- ①：这张卡同调召唤成功的场合，以自己场上1只「石之世界的石神千空」和场上最多2张其他卡为对象才能发动。那些卡破坏。那之后，这张卡变成里侧守备表示。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_DESTROY + CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1, m) -- ①②共享一次
	e1:SetCondition(cm.con1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡变成表侧表示的场合，以场上最多2张卡为对象才能发动。那些卡破坏。这张卡回到额外卡组。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_DESTROY + CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_FLIP)
	e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1, m) -- ①②共享一次
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

-- ========== ① ==========
function cm.con1(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function cm.senkufilter(c)
	return c:IsCode(71000120) and c:IsFaceup()
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(cm.senkufilter, tp, LOCATION_MZONE, 0, 1, nil)
	end
	-- 1. 选千空
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
	local g1 = Duel.SelectMatchingCard(tp, cm.senkufilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
	-- 2. 选其他卡（用 Filter 排除已选的千空，避免重复）
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
	local g2 = Duel.SelectMatchingCard(tp, Card.IsOnField, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 0, 2, g1)
	g1:Merge(g2)
	Duel.SetTargetCard(g1)
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, g1, g1:GetCount(), 0, 0)
end

-- ① 操作：破坏 → 自身变里侧守备
function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local tg = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
	if tg and tg:GetCount() > 0 then
		Duel.Destroy(tg, REASON_EFFECT)
	end
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() then
		Duel.ChangePosition(c, POS_FACEDOWN_DEFENSE)
	end
end

-- ========== ② ==========
function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then
		return chkc:IsOnField()
	end
	if chk == 0 then
		return Duel.IsExistingTarget(nil, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
	local g = Duel.SelectTarget(tp, nil, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 2, nil)
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, g:GetCount(), 0, 0)
end

-- ② 操作：破坏 → 自身回额外卡组
function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local tg = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
	if tg and tg:GetCount() > 0 then
		Duel.Destroy(tg, REASON_EFFECT)
	end
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE) then
		Duel.SendtoDeck(c, tp, SEQ_DECKSHUFFLE, REASON_EFFECT)
	end
end