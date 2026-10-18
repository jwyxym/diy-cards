--石之世界的西瓜
-- 卡片类型：怪兽卡, 效果, 调整
-- 地 2星 植物族 300/800
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：对方场上有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	--     那之后，确认对方卡组上面3张卡，用喜欢的顺序回到卡组上面。这张卡变成里侧守备表示。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1, m)
	e1:SetCondition(cm.con1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡变成表侧表示的场合，以自己墓地1只「石之世界」怪兽为对象才能发动。
	--     那只怪兽效果无效特殊召唤。特殊召唤的怪兽是「石之世界的石神千空」的场合，
	--     可以再从卡组·墓地把1张「石之世界的复活药剂」在自己的魔法与陷阱区域盖放。
	--     那之后，那只怪兽变成里侧守备表示。这个效果盖放的卡在盖放的回合也能发动。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_FLIP)
	e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1, m + 1)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

-- ========== ① ==========
-- ① 条件：自己场上有空位，且对方场上有怪兽
function cm.con1(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
		and Duel.IsExistingMatchingCard(Card.IsMonster, tp, 0, LOCATION_MZONE, 1, nil)
end

-- ① 目标
function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
			and Duel.IsExistingMatchingCard(Card.IsMonster, tp, 0, LOCATION_MZONE, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, tp, LOCATION_HAND)
end

-- ① 操作：特召自己（攻击表示） → 确认对方卡组顶部3张并重排 → 自己变成里侧守备
function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_ATTACK) == 0 then return end

	-- 确认对方卡组顶部最多3张
	local opp = 1 - tp
	local ct = math.min(3, Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK))
	if ct > 0 then
		-- 修复：确认的是对手的卡组顶
		Duel.ConfirmDecktop(opp, ct)
		Duel.SortDecktop(tp, opp, ct)
	end

	-- 修复：去掉 IsRelateToEffect，直接看位置和表侧状态，避免跳过变里侧代码
	if c:IsLocation(LOCATION_MZONE) and c:IsFaceup() then
		Duel.ChangePosition(c, POS_FACEDOWN_DEFENSE)
	end
end

-- ========== ② ==========
-- 「石之世界」怪兽过滤
function cm.spfilter(c, e, tp)
	return c:IsSetCard(0x3e12) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

-- ② 目标：自己墓地1只「石之世界」怪兽
function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cm.spfilter(chkc, e, tp)
	end
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
			and Duel.IsExistingTarget(cm.spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectTarget(tp, cm.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

-- ② 操作：特召（效果无效）→ 若是石神千空可盖放复活药剂 → 变成里侧守备
function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	-- 以攻击表示特殊召唤
	if Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP_ATTACK) == 0 then return end

	-- 效果无效
	local e1 = Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT + RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2 = Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT + RESETS_STANDARD)
	tc:RegisterEffect(e2)

	-- 如果特召的是「石之世界的石神千空」，可以盖放「石之世界的复活药剂」
	if tc:IsCode(71000120)
		and Duel.IsExistingMatchingCard(cm.setfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
		and Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
		and Duel.SelectYesNo(tp, aux.Stringid(m, 2)) then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
		local sg = Duel.SelectMatchingCard(tp, cm.setfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
		if #sg > 0 then
			Duel.SSet(tp, sg)
			-- 盖放的卡在盖放的回合也能发动
			for s in aux.Next(sg) do
				local ee = Effect.CreateEffect(e:GetHandler())
				ee:SetType(EFFECT_TYPE_SINGLE)
				ee:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
				ee:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				ee:SetReset(RESET_EVENT + RESETS_STANDARD)
				s:RegisterEffect(ee)
			end
		end
	end

	-- 修复：去掉 IsRelateToEffect，直接看位置和表侧状态，确保变成里侧守备
	if tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		Duel.ChangePosition(tc, POS_FACEDOWN_DEFENSE)
	end
end

-- 「石之世界的复活药剂」过滤
function cm.setfilter(c)
	return c:IsCode(71000126) and c:IsSSetable()
end