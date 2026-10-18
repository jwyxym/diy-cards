--石之世界的七海龙水
-- 卡片类型：怪兽卡, 同调, 效果
-- 地 7星 战士族 2500/2000
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

	-- ①：这张卡同调召唤成功的场合才能发动。从自己卡组·墓地把1张「石之世界的复活药剂」盖放到自己的魔法与陷阱区域，这个效果盖放的卡在盖放的回合也能发动。自己场上有「石之世界的石神千空」存在的场合，也能再从卡组把1只「石之世界的弗朗索瓦」特殊召唤。那之后这张卡变成里侧守备表示。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_SSET + CATEGORY_SPECIAL_SUMMON + CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1, m)
	e1:SetCondition(cm.con1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡变成表侧表示的场合才能发动。从自己卡组·墓地把1张「石之世界的科学道具 珀尔修斯号」放置到自己的魔法与陷阱区域。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_SSET)
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
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

-- ① 过滤：复活药剂（速攻魔法，可盖放）
function cm.setfilter1(c)
	return c:IsCode(71000126) and c:IsSSetable()
end
-- ① 过滤：弗朗索瓦（可从卡组特召）
function cm.spfilter1(c, e, tp)
	return c:IsCode(71000170) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(cm.setfilter1, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_SSET, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()

	-- 1. 从卡组·墓地盖放「复活药剂」
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
	local g = Duel.SelectMatchingCard(tp, cm.setfilter1, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
	if #g > 0 then
		local sg = g:Clone()
		Duel.SSet(tp, sg)
		-- 盖放的卡在盖放的回合也能发动
		for s in aux.Next(sg) do
			local ee = Effect.CreateEffect(c)
			ee:SetType(EFFECT_TYPE_SINGLE)
			ee:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			ee:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			ee:SetReset(RESET_EVENT + RESETS_STANDARD)
			s:RegisterEffect(ee)
		end
	end

	-- 2. 如果场上有千空，可以再从卡组特召弗朗索瓦
	local hasSenku = Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_MZONE, 0, 1, nil, 71000120)
	if hasSenku and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
		local sg2 = Duel.GetMatchingGroup(cm.spfilter1, tp, LOCATION_DECK, 0, nil, e, tp)
		if sg2:GetCount() > 0 then
			if Duel.SelectYesNo(tp, aux.Stringid(m, 2)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
				local tg = sg2:Select(tp, 1, 1, nil)
				if #tg > 0 then
					Duel.SpecialSummon(tg, 0, tp, tp, false, false, POS_FACEUP_ATTACK)
				end
			end
		end
	end

	-- 3. 那之后，这张卡变成里侧守备表示
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() then
		Duel.ChangePosition(c, POS_FACEDOWN_DEFENSE)
	end
end

-- ========== ② ==========
-- ② 过滤：珀尔修斯号
function cm.setfilter2(c)
	return c:IsCode(71000182) and c:IsSSetable()
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
			and Duel.IsExistingMatchingCard(cm.setfilter2, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_SSET, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
	local g = Duel.SelectMatchingCard(tp, cm.setfilter2, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
	if #g > 0 then
		local tc = g:GetFirst()
		-- 表侧放置
		Duel.MoveToField(tc, tp, tp, LOCATION_SZONE, POS_FACEUP, true)
	end
end