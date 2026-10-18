--石之世界的石化装置
-- 卡片类型：魔法卡, 速攻
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, m)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：双方主要阶段才能发动。下次的自己或对方回合开始时，场上的全部怪兽变成里侧守备表示。这个效果发动后，直到自己下个回合结束，自己的怪兽不能攻击宣言。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1, m + 1)
	e2:SetCondition(cm.con2)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

-- ========== ① ==========
function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup()
	end
	if chk == 0 then
		return Duel.IsExistingTarget(Card.IsFaceup, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
	local g = Duel.SelectTarget(tp, Card.IsFaceup, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_POSITION, g, 1, 0, 0)
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	Duel.ChangePosition(tc, POS_FACEDOWN_DEFENSE)
end

-- ========== ② ==========
function cm.con2(e, tp, eg, ep, ev, re, r, rp)
	local ph = Duel.GetCurrentPhase()
	return ph == PHASE_MAIN1 or ph == PHASE_MAIN2
end

-- 【修改】不再要求场上有表侧怪兽
function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		local ph = Duel.GetCurrentPhase()
		return ph == PHASE_MAIN1 or ph == PHASE_MAIN2
	end
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local turn = Duel.GetTurnCount()
	local is_my_turn = (Duel.GetTurnPlayer() == tp)

	-- 【延迟翻面】下一个回合开始时，场上所有表侧怪兽变里侧守备
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE + PHASE_DRAW)
	e1:SetOperation(cm.op2_sp)
	e1:SetLabel(turn)
	e1:SetReset(RESET_PHASE + PHASE_END, 3)
	Duel.RegisterEffect(e1, tp)

	-- 【不能攻击宣言】
	local reset_count = is_my_turn and 3 or 2
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(1, 0)
	e2:SetReset(RESET_PHASE + PHASE_END, reset_count)
	Duel.RegisterEffect(e2, tp)
end

function cm.op2_sp(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetTurnCount() == e:GetLabel() then return end
	local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
	for tc in aux.Next(g) do
		Duel.ChangePosition(tc, POS_FACEDOWN_DEFENSE)
	end
	e:Reset()
end