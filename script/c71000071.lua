--大墓之魂归
-- 卡片类型：陷阱卡, 永续
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- 永续陷阱效果
	local e0 = Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- ①：自己场上有对方怪兽存在，对方怪兽的效果发动时才能发动。选自己场上1只对方怪兽送去墓地。那个效果无效并破坏。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_DESTROY + CATEGORY_TOGRAVE + CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1, m + 1)
	e1:SetCondition(cm.condition1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡从场上或被「大墓」卡的效果送去墓地的场合才能发动。选自己墓地1张「大墓」陷阱卡盖放到自己的魔法与陷阱区域。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1, m + 2)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(cm.condition2)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

function cm.condition1(e, tp, eg, ep, ev, re, rp)
	local rc = re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsControler(1 - tp) and
		Duel.IsExistingMatchingCard(cm.costfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, 1, 0, 0)
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	-- 选自己场上1只原本持有者为对方的怪兽送去墓地
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g = Duel.SelectMatchingCard(tp, cm.costfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
	local rc = re:GetHandler()
	if #g > 0 and Duel.SendtoGrave(g, REASON_EFFECT) > 0 then
		-- 那个效果无效并破坏
		Duel.NegateEffect(ev)
		if rc:IsRelateToEffect(re) then
			Duel.Destroy(rc, REASON_EFFECT)
		end
	end
end

function cm.condition2(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and (r & REASON_EFFECT ~= 0 or (re and re:GetHandler():IsSetCard(0x3e11)))
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsSetCard(0x3e11) and
			chkc:IsType(TYPE_TRAP) and chkc:IsSSetable()
	end
	if chk == 0 then
		return Duel.IsExistingTarget(cm.filter, tp, LOCATION_GRAVE, 0, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
	local g = Duel.SelectTarget(tp, cm.filter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, g, 1, 0, 0)
end

function cm.filter(c)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end

function cm.costfilter(c)
	return c:GetOwner() ~= c:GetControler()
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsSSetable() and Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 then
		Duel.SSet(tp, tc)
		Duel.ConfirmCards(1 - tp, tc)
	end
end
