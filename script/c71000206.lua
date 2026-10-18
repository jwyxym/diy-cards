--石之世界的琥珀
-- 卡片类型：怪兽卡, 同调, 调整, 效果
-- 地 5星 战士族 1900/2200
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

	-- ①：这张卡的攻击力与守备力上升场上的里侧守备表示怪兽数量×300。
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cm.atkval)
	c:RegisterEffect(e1)
	local e2 = e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)

	-- ②：这张卡进行战斗的伤害步骤结束时，以对方场上1只怪兽为对象才能发动。那只怪兽回到持有者手卡，那之后，这张卡变成里侧守备表示。
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m, 0))
	e3:SetCategory(CATEGORY_TOHAND + CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1, m)
	e3:SetCondition(cm.battlecon)
	e3:SetTarget(cm.battletg)
	e3:SetOperation(cm.battleop)
	c:RegisterEffect(e3)

	-- ③：这张卡变成表侧表示的场合才能发动。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
	local e4 = Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(m, 1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_FLIP)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1, m + 1)
	e4:SetTarget(cm.syntg)
	e4:SetOperation(cm.synop)
	c:RegisterEffect(e4)
end

-- ========== ① ==========
function cm.atkval(e)
	local c = e:GetHandler()
	if not c:IsFaceup() then return 0 end
	local g = Duel.GetMatchingGroup(Card.IsFacedown, 0, LOCATION_MZONE, LOCATION_MZONE, nil)
	return g:GetCount() * 300
end

-- ========== ② ==========
function cm.battlecon(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	return Duel.GetAttacker() == c or Duel.GetAttackTarget() == c
end
function cm.battletg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1 - tp) end
	if chk == 0 then
		return Duel.IsExistingTarget(nil, tp, 0, LOCATION_MZONE, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_BOUNCE)
	local g = Duel.SelectTarget(tp, nil, tp, 0, LOCATION_MZONE, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
end
function cm.battleop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local tc = Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc, nil, REASON_EFFECT)
	end
	-- 那之后，这张卡变成里侧守备表示
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() then
		Duel.ChangePosition(c, POS_FACEDOWN_DEFENSE)
	end
end

-- ========== ③ ==========
function cm.syncheck(g, tp, syncard, hc)
	if not g:IsContains(hc) then return false end
	return syncard:IsSynchroSummonable(nil, g, #g-1, #g-1)
end
function cm.scfilter(c, tp, mg, hc)
	return mg:CheckSubGroup(cm.syncheck, 2, #mg, tp, c, hc)
end
function cm.syntg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		local c = e:GetHandler()
		if not c:IsFaceup() then return false end
		local mg = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
		return Duel.IsExistingMatchingCard(cm.scfilter, tp, LOCATION_EXTRA, 0, 1, nil, tp, mg, c)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end
function cm.synop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
	local mg = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
	local g = Duel.GetMatchingGroup(cm.scfilter, tp, LOCATION_EXTRA, 0, nil, tp, mg, c)
	if g:GetCount() == 0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local sc = g:Select(tp, 1, 1, nil):GetFirst()
	if not sc then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SMATERIAL)
	local tg = mg:SelectSubGroup(tp, cm.syncheck, false, 2, #mg, tp, sc, c)
	if not tg or tg:GetCount() == 0 then return end
	Duel.SynchroSummon(tp, sc, nil, tg, #tg-1, #tg-1)
end