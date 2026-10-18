--石之世界的复活药剂
-- 卡片类型：魔法卡, 速攻
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：以场上1只里侧表示怪兽为对象才能发动。那只怪兽变成表侧攻击表示。那之后，直到回合结束时，那只怪兽不会被效果破坏。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：双方主要阶段才能发动。下次的自己或对方回合开始时，场上的里侧表示怪兽全部变成表侧表示。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1, m + 100)
	e2:SetCondition(cm.con2)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

-- ========== ① ==========
function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFacedown()
	end
	if chk == 0 then
		return Duel.IsExistingTarget(Card.IsFacedown, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
	local g = Duel.SelectTarget(tp, Card.IsFacedown, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_POSITION, g, 1, 0, 0)
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFacedown() then return end
	if Duel.ChangePosition(tc, POS_FACEUP_ATTACK) > 0 then
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
		tc:RegisterEffect(e1)
	end
end

-- ========== ② ==========
function cm.con2(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsMainPhase()
end

-- 【修改】不再要求场上有里侧怪兽
function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsMainPhase()
	end
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE + PHASE_DRAW)
	e1:SetOperation(cm.op2_sp)
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetReset(RESET_PHASE + PHASE_END, 2)
	Duel.RegisterEffect(e1, tp)
end

function cm.op2_sp(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetTurnCount() == e:GetLabel() then return end
	local g = Duel.GetMatchingGroup(Card.IsFacedown, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
	for tc in aux.Next(g) do
		Duel.ChangePosition(tc, POS_FACEUP_DEFENSE)
	end
	e:Reset()
end