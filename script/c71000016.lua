--大墓之埋葬者
-- 卡片类型：怪兽卡, 效果
-- 暗 6星 不死族 1800/1800
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合才能发动。这张卡从手卡·墓地特殊召唤。那之后，把自己手卡·场上1张卡送去墓地，从自己墓地把1只怪兽加入手卡。这个效果发动后，这个回合自己不是「大墓」怪兽不能从手卡·卡组·额外卡组特殊召唤。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOGRAVE + CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
	e1:SetCountLimit(1, m + 1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡被效果送去墓地的场合，以自己墓地1张「大墓」陷阱卡为对象才能发动。那张卡盖放到自己场上。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1, m + 2)
	e2:SetCondition(cm.condition2)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

-- ========== ① ==========
-- 目标阶段：必须同时满足 1.可特召自身 2.有其他卡可送墓 3.墓地有怪兽可回收
function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then
		local can_send = Duel.IsExistingMatchingCard(Card.IsAbleToGrave, tp, LOCATION_HAND + LOCATION_ONFIELD, 0, 1, c)
		local can_add = Duel.IsExistingMatchingCard(cm.thfilter, tp, LOCATION_GRAVE, 0, 1, nil)
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
			c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
			can_send and can_add
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, c:GetLocation())
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	
	-- 1. 从手卡·墓地特召自身
	if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
		
		-- 2. 【核心修改】去掉了 SelectYesNo，变成了强制执行的处理
		local can_send = Duel.IsExistingMatchingCard(Card.IsAbleToGrave, tp, LOCATION_HAND + LOCATION_ONFIELD, 0, 1, c)
		local can_add = Duel.IsExistingMatchingCard(cm.thfilter, tp, LOCATION_GRAVE, 0, 1, nil)
		
		if can_send and can_add then
			Duel.BreakEffect()
			-- 强制选1张卡送去墓地
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
			local g = Duel.SelectMatchingCard(tp, Card.IsAbleToGrave, tp, LOCATION_HAND + LOCATION_ONFIELD, 0, 1, 1, c)
			if #g > 0 then
				Duel.SendtoGrave(g, REASON_EFFECT)
				Duel.BreakEffect()
				-- 强制从墓地选1只怪兽加入手卡
				Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
				local sg = Duel.SelectMatchingCard(tp, cm.thfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
				if #sg > 0 then
					Duel.SendtoHand(sg, nil, REASON_EFFECT)
					Duel.ConfirmCards(1 - tp, sg)
					Duel.ShuffleHand(tp)
				end
			end
		end
		
		-- 3. 限制：这个回合自己不是「大墓」怪兽不能从手卡·卡组·额外卡组特殊召唤
		local e1 = Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1, 0)
		e1:SetTarget(cm.splimit)
		e1:SetReset(RESET_PHASE + PHASE_END)
		Duel.RegisterEffect(e1, tp)
	end
end

-- 墓地怪兽加入手卡的过滤
function cm.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

-- 特召限制：必须是「大墓」怪兽才能从 手卡·卡组·额外卡组 特召
function cm.splimit(e, c, sump, sumtype, sumpos, targetp, se)
	if c:IsLocation(LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA) then
		return not (c:IsSetCard(0x3e11) and c:IsType(TYPE_MONSTER))
	end
	return false
end

-- ========== ② ==========
-- 条件：被效果送去墓地
function cm.condition2(e, tp, eg, ep, ev, re, r, rp)
	return bit.band(r, REASON_EFFECT) ~= 0
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cm.filter(chkc)
	end
	if chk == 0 then
		return Duel.IsExistingTarget(cm.filter, tp, LOCATION_GRAVE, 0, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
	local g = Duel.SelectTarget(tp, cm.filter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, g, 1, 0, 0)
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SSet(tp, tc)
	end
end

function cm.filter(c)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end