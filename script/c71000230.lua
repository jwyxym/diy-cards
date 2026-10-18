--石之世界的久远遗音
-- 卡片类型：魔法卡, 通常
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，或者自己场上只有里侧表示怪兽存在的场合才能发动。从卡组把最多2只「石之世界」怪兽里侧守备表示特殊召唤。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, m)
	e1:SetCondition(cm.con1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：把墓地的这张卡除外才能发动。把1张「石之世界的复活药剂」从自己墓地·除外状态加入手卡。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1, m + 1)
	e2:SetCost(aux.bfgcost) -- 除外自身作为代价
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

-- ========== ① ==========
-- ① 条件：自己场上没有怪兽，或者只有里侧表示怪兽
function cm.con1(e, tp, eg, ep, ev, re, r, rp)
	local g = Duel.GetFieldGroup(tp, LOCATION_MZONE, 0)
	-- 场上没有怪兽
	if g:GetCount() == 0 then return true end
	-- 场上只有里侧表示怪兽
	local faceup_mon = g:Filter(Card.IsFaceup, nil)
	return faceup_mon:GetCount() == 0
end

-- ① 特召过滤：「石之世界」怪兽
function cm.spfilter(c, e, tp)
	return c:IsSetCard(0x3e12) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
			and Duel.IsExistingMatchingCard(cm.spfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

-- ① 操作：从卡组选最多2只特召（里侧守备）
function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local ct = math.min(2, Duel.GetLocationCount(tp, LOCATION_MZONE))
	if ct <= 0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, cm.spfilter, tp, LOCATION_DECK, 0, 1, ct, nil, e, tp)
	if #g == 0 then return end
	for tc in aux.Next(g) do
		Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEDOWN_DEFENSE)
	end
	Duel.SpecialSummonComplete()
end

-- ========== ② ==========
-- ② 目标：墓地·除外状态的「复活药剂」
function cm.thfilter(c)
	return c:IsCode(71000126) and c:IsAbleToHand()
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(cm.thfilter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE + LOCATION_REMOVED)
end

-- ② 操作：从墓地·除外状态回收「复活药剂」
function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, cm.thfilter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, g)
		Duel.ShuffleHand(tp)
	end
end