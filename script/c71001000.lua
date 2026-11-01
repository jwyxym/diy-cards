--WHYMAN
-- 卡片类型：怪兽卡, 同调, 效果
-- 光 12星 机械族 0/5000
local cm, m, o = GetID()

function cm.tuner_filter(c)
	return c and c:IsType(TYPE_TUNER) and c:IsType(TYPE_SYNCHRO)
end
function cm.nontuner_filter(c)
	return c and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TUNER)
end

function cm.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c, cm.tuner_filter, cm.nontuner_filter, 1, 2)

	-- ①：这张卡同调召唤成功的场合发动。这张卡以外的怪兽全部变成里侧守备表示。
	-- （去掉了可能导致崩溃的全抗标志位，改为普通的效果）
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1, m)
	e1:SetCondition(cm.con1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：1回合1次。对方发动场上怪兽的效果的场合才能发动。那些怪兽变成里侧守备表示。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1, m + 1)
	e2:SetCondition(cm.con2)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)

	-- ③：同调召唤的这张卡在我方下个回合的准备阶段开始时里侧表示除外。
	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE + PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(cm.excon)
	e3:SetOperation(cm.exop)
	c:RegisterEffect(e3)

	-- ④：只要这张卡在场上表侧表示存在，对方不能把怪兽反转召唤。
	-- 使用最标准的禁止反转召唤代码
	local e4 = Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0, 1) -- 影响对方
	c:RegisterEffect(e4)
end

-- ========== ① ==========
function cm.con1(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, LOCATION_MZONE, c)
	for tc in aux.Next(g) do
		Duel.ChangePosition(tc, POS_FACEDOWN_DEFENSE)
	end
end

-- ========== ② ==========
function cm.con2(e, tp, eg, ep, ev, re, r, rp)
	if not re:IsActiveType(TYPE_MONSTER) then return false end
	local rc = re:GetHandler()
	return rc and rc:IsControler(1 - tp) and rc:IsLocation(LOCATION_MZONE) and rc:IsFaceup()
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return true end
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local rc = re:GetHandler()
	if rc and rc:IsRelateToEffect(re) and rc:IsLocation(LOCATION_MZONE) and rc:IsFaceup() then
		Duel.ChangePosition(rc, POS_FACEDOWN_DEFENSE)
	end
end

-- ========== ③ ==========
function cm.excon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetTurnPlayer() == tp and e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function cm.exop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Remove(e:GetHandler(), POS_FACEDOWN, REASON_EFFECT)
end