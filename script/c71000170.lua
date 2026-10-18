--石之世界的弗朗索瓦
-- 卡片类型：怪兽卡, 效果, 调整
-- 地 3星 魔法师族 400/1000
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：自己场上有「石之世界的七海龙水」存在的场合才能发动。这张卡从手卡·墓地特殊召唤。那之后，自己回复800基本分，这张卡变成里侧守备表示。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_RECOVER + CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
	e1:SetCountLimit(1, m)
	e1:SetCondition(cm.con1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡在自己场上表侧表示的场合才能发动。用这张卡和自己墓地1只4星怪兽作为同调素材回到卡组，把1只「石之世界的七海龙水」同调召唤。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1, m + 1)
	e2:SetCondition(cm.con2)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

-- ========== ① ==========
function cm.con1(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsExistingMatchingCard(cm.filter1, tp, LOCATION_MZONE, 0, 1, nil)
		and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
end
function cm.filter1(c) return c:IsCode(71000176) and c:IsFaceup() end
function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return cm.con1(e, tp, eg, ep, ev, re, r, rp) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, tp, LOCATION_HAND + LOCATION_GRAVE)
	Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, 800)
end
function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_ATTACK) > 0 then
		Duel.Recover(tp, 800, REASON_EFFECT)
		if c:IsLocation(LOCATION_MZONE) and c:IsFaceup() then
			Duel.ChangePosition(c, POS_FACEDOWN_DEFENSE)
		end
	end
end

-- ========== ② ==========
function cm.con2(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():IsFaceup()
end

-- 墓地素材过滤：必须是4星怪兽，且可以回卡组
function cm.matfilter(c)
	return c:IsType(TYPE_MONSTER) and c:GetLevel() == 4 and c:IsAbleToDeck()
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		-- 检查墓地是否有4星怪兽，且额外卡组有七海龙水
		if not Duel.IsExistingMatchingCard(cm.matfilter, tp, LOCATION_GRAVE, 0, 1, nil) then return false end
		return Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_EXTRA, 0, 1, nil, 71000176)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

-- ② 操作：选墓地4星怪兽 → 两者回卡组 → 同调召唤七海龙水
function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	-- 1. 从墓地选1只4星怪兽
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local mat_tc = Duel.SelectMatchingCard(tp, cm.matfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil):GetFirst()
	if not mat_tc then return end

	-- 2. 找到额外卡组的「石之世界的七海龙水」
	local tc = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_EXTRA, 0, nil, 71000176):GetFirst()
	if not tc then return end

	-- 3. 组合素材：弗朗索瓦 + 墓地4星怪兽
	local mat = Group.CreateGroup()
	mat:AddCard(c)
	mat:AddCard(mat_tc)

	tc:SetMaterial(mat)
	-- 两者回到卡组
	Duel.SendtoDeck(mat, nil, SEQ_DECKSHUFFLE, REASON_EFFECT + REASON_MATERIAL + REASON_SYNCHRO)
	Duel.BreakEffect()

	-- 4. 以同调召唤的形式特殊召唤七海龙水
	Duel.SpecialSummon(tc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP_ATTACK)
	tc:CompleteProcedure()
end