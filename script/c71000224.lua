--石之世界3700年
-- 卡片类型：魔法卡, 场地
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理。可以从手卡·墓地·卡组把1只「石之世界的石神千空」里侧表示特殊召唤，把1张「石之世界的复活药剂」加入手卡。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOHAND + CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, m)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：双方的结束阶段才能发动。从自己卡组·墓地把1张「石之世界的复活药剂」盖放到自己的魔法与陷阱区域。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE + PHASE_END)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1, m + 1)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

-- ========== ① ==========
-- ① 千空过滤：可从手卡/墓地/卡组里侧特召
function cm.spfilter(c, e, tp)
	return c:IsCode(71000120) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

-- ① 复活药剂过滤
function cm.thfilter(c)
	return c:IsCode(71000126) and c:IsAbleToHand()
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		local can_sp = Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
			and Duel.IsExistingMatchingCard(cm.spfilter, tp, LOCATION_HAND + LOCATION_GRAVE + LOCATION_DECK, 0, 1, nil, e, tp)
		local can_th = Duel.IsExistingMatchingCard(cm.thfilter, tp, LOCATION_DECK, 0, 1, nil)
		return can_sp or can_th
	end
	-- 记录是否可特召，供 op1 使用
	local can_sp = Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
		and Duel.IsExistingMatchingCard(cm.spfilter, tp, LOCATION_HAND + LOCATION_GRAVE + LOCATION_DECK, 0, 1, nil, e, tp)
	e:SetLabel(can_sp and 1 or 0)
	if can_sp then
		Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_GRAVE + LOCATION_DECK)
	end
	if Duel.IsExistingMatchingCard(cm.thfilter, tp, LOCATION_DECK, 0, 1, nil) then
		Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
	end
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local can_sp = e:GetLabel() == 1

	-- 1. 如果可以，从手卡·墓地·卡组特召千空（里侧守备）
	if can_sp and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local g = Duel.SelectMatchingCard(tp, cm.spfilter, tp, LOCATION_HAND + LOCATION_GRAVE + LOCATION_DECK, 0, 1, 1, nil, e, tp)
		if #g > 0 then
			Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEDOWN_DEFENSE)
		end
	end

	-- 2. 从卡组把1张「石之世界的复活药剂」加入手卡
	Duel.BreakEffect()
	if Duel.IsExistingMatchingCard(cm.thfilter, tp, LOCATION_DECK, 0, 1, nil) then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
		local sg = Duel.SelectMatchingCard(tp, cm.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
		if #sg > 0 then
			Duel.SendtoHand(sg, nil, REASON_EFFECT)
			Duel.ConfirmCards(1 - tp, sg)
			Duel.ShuffleHand(tp)
		end
	end
end

-- ========== ② ==========
function cm.setfilter(c)
	return c:IsCode(71000126) and c:IsSSetable()
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
			and Duel.IsExistingMatchingCard(cm.setfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_SSET, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
	local g = Duel.SelectMatchingCard(tp, cm.setfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SSet(tp, g)
	end
end