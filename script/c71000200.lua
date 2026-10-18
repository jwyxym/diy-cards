--石之世界的金狼银狼
-- 卡片类型：怪兽卡, 效果
-- 地 4星 兽战士族 2000/1800
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：自己场上有这张卡以外的「石之世界」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，从卡组把1只「石之世界」怪兽特殊召唤，这张卡变成里侧守备表示。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1, m)
	e1:SetCondition(cm.con1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡变成表侧表示的场合，以自己场上1只调整以外的「石之世界」怪兽为对象才能发动。那只怪兽当作调整使用。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_FLIP)
	e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1, m + 1)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

-- ========== ① ==========
function cm.con1(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
		and Duel.IsExistingMatchingCard(cm.filter1, tp, LOCATION_MZONE, 0, 1, nil)
end
function cm.filter1(c)
	return c:IsSetCard(0x3e12) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return cm.con1(e, tp, eg, ep, ev, re, r, rp)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, tp, LOCATION_HAND)
end

function cm.spfilter1(c, e, tp)
	return c:IsSetCard(0x3e12) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_ATTACK) == 0 then return end

	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, cm.spfilter1, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
	if #g > 0 then
		Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP_ATTACK)
	end

	if c:IsLocation(LOCATION_MZONE) and c:IsFaceup() then
		Duel.ChangePosition(c, POS_FACEDOWN_DEFENSE)
	end
end

-- ========== ② ==========
function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cm.filter2(chkc)
	end
	if chk == 0 then
		return Duel.IsExistingTarget(cm.filter2, tp, LOCATION_MZONE, 0, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
	local g = Duel.SelectTarget(tp, cm.filter2, tp, LOCATION_MZONE, 0, 1, 1, nil)
end

-- ② 目标过滤：必须是「石之世界」怪兽，且不是调整
function cm.filter2(c)
	return c:IsSetCard(0x3e12) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
		and not c:IsType(TYPE_TUNER)
end

-- 【核心】用 EFFECT_ADD_TYPE + TYPE_TUNER，让引擎真正识别为调整怪兽
function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local e1 = Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetValue(TYPE_TUNER)
	e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
	tc:RegisterEffect(e1)
end