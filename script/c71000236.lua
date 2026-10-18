--石之世界的防风护壁
-- 卡片类型：陷阱卡, 通常
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：对方把魔法·陷阱卡发动的场合，把自己场上1只表侧表示怪兽变成里侧守备表示才能发动，那个发动无效并破坏。那之后，可以从自己墓地把1张「石之世界的复活药剂」加入手卡。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY + CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCountLimit(1, m)
	e1:SetCondition(cm.con1)
	e1:SetCost(cm.cost1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：自己场上的怪兽被破坏的场合，把墓地的这张卡除外才能发动。从自己墓地把1只「石之世界」怪兽特殊召唤。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1, m + 1)
	e2:SetCondition(cm.con2)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

-- ========== ① ==========
-- ① 条件：对方发动魔法·陷阱卡
function cm.con1(e, tp, eg, ep, ev, re, r, rp)
	return rp == 1 - tp
		and (re:IsActiveType(TYPE_SPELL) or re:IsActiveType(TYPE_TRAP))
		and Duel.IsChainNegatable(ev)
end

-- ① 代价：把自己场上1只表侧怪兽变里侧守备
function cm.costfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
function cm.cost1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(cm.costfilter, tp, LOCATION_MZONE, 0, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_POSCHANGE)
	local g = Duel.SelectMatchingCard(tp, cm.costfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
	if #g == 0 then return end
	Duel.HintSelection(g)
	Duel.ChangePosition(g, POS_FACEDOWN_DEFENSE)
end

-- ① 目标
function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
end

-- ① 操作：无效并破坏，然后可选回收
function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	-- 无效并破坏
	Duel.NegateActivation(ev)
	local rc = re:GetHandler()
	if rc and rc:IsRelateToEffect(re) then
		Duel.Destroy(rc, REASON_EFFECT)
	end
	-- 那之后，可从墓地回收「复活药剂」
	if Duel.IsExistingMatchingCard(cm.thfilter, tp, LOCATION_GRAVE, 0, 1, nil)
		and Duel.SelectYesNo(tp, aux.Stringid(m, 2)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
		local g = Duel.SelectMatchingCard(tp, cm.thfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
		if #g > 0 then
			Duel.SendtoHand(g, nil, REASON_EFFECT)
			Duel.ConfirmCards(1 - tp, g)
			Duel.ShuffleHand(tp)
		end
	end
end

function cm.thfilter(c)
	return c:IsCode(71000126) and c:IsAbleToHand()
end

-- ========== ② ==========
-- ② 条件：自己场上的怪兽被破坏
function cm.con2(e, tp, eg, ep, ev, re, r, rp)
	return eg:IsExists(cm.cfilter2, 1, nil, tp)
end
function cm.cfilter2(c, tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and c:IsType(TYPE_MONSTER) and c:IsReason(REASON_DESTROY)
end

-- ② 特召过滤：「石之世界」怪兽
function cm.spfilter2(c, e, tp)
	return c:IsSetCard(0x3e12) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

-- ② 目标
function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
			and Duel.IsExistingMatchingCard(cm.spfilter2, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
end

-- ② 操作：从墓地特召
function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, cm.spfilter2, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
	if #g > 0 then
		Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP_ATTACK)
	end
end