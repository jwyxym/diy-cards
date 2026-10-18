--石之世界的克罗姆
-- 卡片类型：怪兽卡, 效果
-- 地 4星 魔法师族 1800/1800
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：自己场上有这张卡以外的「石之世界」怪兽存在的场合才能发动。从卡组把1张「石之世界」魔法卡加入手卡，这张卡从手卡里侧守备表示特殊召唤。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1, m)
	e1:SetCondition(cm.con1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡变成表侧表示的场合才能发动，从墓地把1张「石之世界」魔法卡加入手卡，自己场上有「石之世界的石神千空」的场合，也能不加入手卡直接盖放到自己的魔法与陷阱区域，这个效果盖放的卡在盖放的回合也能发动。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_FLIP)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1, m + 1)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

-- ========== ① ==========
function cm.con1(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
		and Duel.IsExistingMatchingCard(cm.filter1, tp, LOCATION_MZONE, 0, 1, nil)
		and Duel.IsExistingMatchingCard(cm.thfilter1, tp, LOCATION_DECK, 0, 1, nil)
end
function cm.filter1(c)
	return c:IsSetCard(0x3e12) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
function cm.thfilter1(c)
	return c:IsSetCard(0x3e12) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return cm.con1(e, tp, eg, ep, ev, re, r, rp)
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, tp, LOCATION_HAND)
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	-- 1. 检索
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, cm.thfilter1, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, g)
		Duel.ShuffleHand(tp)
	end
	-- 2. 自身里侧守备特召
	local c = e:GetHandler()
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEDOWN_DEFENSE)
end

-- ========== ② ==========
function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(cm.thfilter2, tp, LOCATION_GRAVE, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE)
end

function cm.thfilter2(c)
	return c:IsSetCard(0x3e12) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end

-- ② 操作：回收 或 盖放（需场上有千空）
function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local hasSenku = Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_MZONE, 0, 1, nil, 71000120)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, cm.thfilter2, tp, LOCATION_GRAVE, 0, 1, 1, nil)
	if #g == 0 then return end
	local tc = g:GetFirst()

	if hasSenku and Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
		and Duel.SelectYesNo(tp, aux.Stringid(m, 2)) then
		-- 标准盖放
		local sg = Group.FromCards(tc)
		Duel.SSet(tp, sg)
		-- 对速攻魔法加"盖放回合可发动"
		for s in aux.Next(sg) do
			local e1 = Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT + RESETS_STANDARD)
			s:RegisterEffect(e1)
		end
	else
		Duel.SendtoHand(tc, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, tc)
		Duel.ShuffleHand(tp)
	end
end