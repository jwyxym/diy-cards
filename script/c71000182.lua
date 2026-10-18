--石之世界的科学道具 珀尔修斯号
-- 卡片类型：魔法卡, 永续
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：自己主要阶段才能发动。从卡组把1张「石之世界」卡加入手卡。那之后，选自己1张手卡回到卡组。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, m)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：自己场上的里侧守备表示怪兽变成表侧表示的场合才能发动，用包含「石之世界」怪兽的自己场上的怪兽为素材进行同调召唤。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_FLIP)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1, m + 1)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(cm.con2)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)

	-- ③：自己场上的「石之世界」怪兽攻击力·守备力上升500点。
	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE, 0)
	e3:SetTarget(cm.atkfilter)
	e3:SetValue(500)
	c:RegisterEffect(e3)
	local e4 = e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
end

-- ========== ① ==========
function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(cm.thfilter, tp, LOCATION_DECK, 0, 1, nil)
			and Duel.IsExistingMatchingCard(Card.IsAbleToDeck, tp, LOCATION_HAND, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function cm.thfilter(c)
	return c:IsSetCard(0x3e12) and c:IsAbleToHand()
end
function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, cm.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, g)
		Duel.ShuffleHand(tp)
	end
	local hg = Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
	if #hg > 0 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
		local sg = hg:Select(tp, 1, 1, nil)
		if #sg > 0 then
			Duel.SendtoDeck(sg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
		end
	end
end

-- ========== ② ==========
function cm.con2(e, tp, eg, ep, ev, re, r, rp)
	return eg:IsExists(cm.cfilter2, 1, nil, tp)
end
function cm.cfilter2(c, tp)
	return c:IsControler(tp) and c:IsPreviousPosition(POS_FACEDOWN) and c:IsFaceup()
end

-- 【核心】素材子集校验：必须包含至少1只「石之世界」怪兽，其他交给引擎按同步怪兽实际要求校验
function cm.syncheck(g, tp, syncard)
	return g:IsExists(Card.IsSetCard, 1, nil, 0x3e12)
		and syncard:IsSynchroSummonable(nil, g, #g-1, #g-1)
end

-- 【核心】过滤函数不传 e，也不检查 IsCanBeSpecialSummoned，直接交给 CheckSubGroup
function cm.scfilter(c, tp, mg)
	return mg:CheckSubGroup(cm.syncheck, 2, #mg, tp, c)
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		local mg = Duel.GetSynchroMaterial(tp)
		if mg:GetCount() < 2 then return false end
		return Duel.IsExistingMatchingCard(cm.scfilter, tp, LOCATION_EXTRA, 0, 1, nil, tp, mg)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local mg = Duel.GetSynchroMaterial(tp)
	if mg:GetCount() < 2 then return end

	-- 找出额外卡组中可以被召唤的同步怪兽
	local g = Duel.GetMatchingGroup(cm.scfilter, tp, LOCATION_EXTRA, 0, nil, tp, mg)
	if g:GetCount() == 0 then return end

	-- 选同步怪兽
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local sg = g:Select(tp, 1, 1, nil)
	local sc = sg:GetFirst()
	if not sc then return end

	-- 【核心】让玩家选素材子集，SelectSubGroup 会自动过滤
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SMATERIAL)
	local tg = mg:SelectSubGroup(tp, cm.syncheck, false, 2, #mg, tp, sc)
	if not tg or tg:GetCount() == 0 then return end

	-- 【核心】：第3参传 nil，第4参传素材组，第5/6参传调整数量范围
	Duel.SynchroSummon(tp, sc, nil, tg, #tg-1, #tg-1)
end

-- ========== ③ ==========
function cm.atkfilter(e, c)
	return c:IsFaceup() and c:IsSetCard(0x3e12)
end