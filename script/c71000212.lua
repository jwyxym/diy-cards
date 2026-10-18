--石之世界的琉璃
-- 卡片类型：怪兽卡, 同调, 效果
-- 地 6星 魔法师族 2200/1800
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
	aux.AddSynchroProcedure(c, cm.tuner_filter, cm.nontuner_filter, 1, 1)

	-- ①：这张卡同调召唤成功的场合才能发动，从卡组把1只「石之世界」怪兽加入手卡。自己场上有「石之世界的石神千空」的场合，也能把那只怪兽特殊召唤。那之后，这张卡变为里侧守备表示。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SPECIAL_SUMMON + CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1, m)
	e1:SetCondition(cm.con1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡变成表侧表示的场合才能发动，从自己墓地·额外卡组把1只「石之世界的琥珀」当做同调召唤特殊召唤。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_FLIP)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1, m + 1)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

-- 【核心修复】手写表侧千空过滤函数，替代 mdPro3 不支持的 aux.FaceupFilter
function cm.senkufilter(c)
	return c:IsFaceup() and c:IsCode(71000120)
end

-- ========== ① ==========
function cm.con1(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function cm.thfilter1(c)
	return c:IsSetCard(0x3e12) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(cm.thfilter1, tp, LOCATION_DECK, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, cm.thfilter1, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g == 0 then return end
	local tc = g:GetFirst()
	-- 【核心修复】使用手写的表侧千空过滤函数
	local hasSenku = Duel.IsExistingMatchingCard(cm.senkufilter, tp, LOCATION_MZONE, 0, 1, nil)
	if hasSenku and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.SelectYesNo(tp, aux.Stringid(m, 2)) then
		Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP_ATTACK)
	else
		Duel.SendtoHand(tc, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, tc)
	end
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() then
		Duel.ChangePosition(c, POS_FACEDOWN_DEFENSE)
	end
end

-- ========== ② ==========
function cm.spfilter2(c, e, tp)
	return c:IsCode(71000206) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false)
end
function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
			and Duel.IsExistingMatchingCard(cm.spfilter2, tp, LOCATION_GRAVE + LOCATION_EXTRA, 0, 1, nil, e, tp)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE + LOCATION_EXTRA)
end
function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, cm.spfilter2, tp, LOCATION_GRAVE + LOCATION_EXTRA, 0, 1, 1, nil, e, tp)
	if #g == 0 then return end
	local tc = g:GetFirst()
	Duel.SpecialSummon(tc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP_ATTACK)
	tc:CompleteProcedure()
end