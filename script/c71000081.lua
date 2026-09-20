--大墓之引魂灯
-- 卡片类型：陷阱卡
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- 永续陷阱效果
	-- local e0 = Effect.CreateEffect(c)
	-- e0:SetType(EFFECT_TYPE_ACTIVATE)
	-- e0:SetCode(EVENT_FREE_CHAIN)
	-- c:RegisterEffect(e0)

	-- -- ①：以自己场上1只「大墓」怪兽为对象才能发动。从卡组把1只卡名不同的「大墓」怪兽效果无效并特殊召唤。
	-- local e1 = Effect.CreateEffect(c)
	-- e1:SetDescription(aux.Stringid(m, 0))
	-- e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_DISABLE)
	-- e1:SetType(EFFECT_TYPE_QUICK_O)
	-- e1:SetCode(EVENT_FREE_CHAIN)
	-- e1:SetRange(LOCATION_SZONE)
	-- e1:SetCountLimit(1, m + 1)
	-- e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- e1:SetTarget(cm.tg1)
	-- e1:SetOperation(cm.op1)
	-- c:RegisterEffect(e1)

	-- -- ②：这张卡从场上或被「大墓」卡的效果送去墓地的场合才能发动，选自己手牌·场上最多2张卡送去墓地。那之中包含对方怪兽的场合，自己抽2张。
	-- local e2 = Effect.CreateEffect(c)
	-- e2:SetDescription(aux.Stringid(m, 1))
	-- e2:SetCategory(CATEGORY_TOGRAVE + CATEGORY_DRAW)
	-- e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	-- e2:SetCode(EVENT_TO_GRAVE)
	-- e2:SetCountLimit(1, m + 2)
	-- e2:SetProperty(EFFECT_FLAG_DELAY)
	-- e2:SetCondition(cm.condition2)
	-- e2:SetTarget(cm.tg2)
	-- e2:SetOperation(cm.op2)
	-- c:RegisterEffect(e2)

	-- 	①：把自己场上1只原本持有者是对方的怪兽送去墓地才能发动。选场上1张卡送去墓地。那之后，从自己或对方墓地选1只怪兽特殊召唤。特殊召唤的是对方怪兽的场合，那只怪兽效果无效，攻击力·守备力变成0，不能作为融合·同调·超量·连接召唤的素材。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_TOGRAVE + CATEGORY_SPECIAL_SUMMON + CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, m + 1)
	e1:SetCost(cm.cost1)
	e1:SetTarget(cm.tg1b)
	e1:SetOperation(cm.op1b)
	c:RegisterEffect(e1)

	-- ②：从自己墓地把这张卡除外才能发动。从自己墓地把1张卡除外，从卡组把1张「大墓」卡送去墓地。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1, m + 2)
	e2:SetCost(cm.cost2b)
	e2:SetTarget(cm.tg2b)
	e2:SetOperation(cm.op2b)
	c:RegisterEffect(e2)
end

function cm.filter(c)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_MONSTER)
end

function cm.filter2(c, tc, e, tp)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_MONSTER) and c:GetCode() ~= tc:GetCode() and
		c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cm.filter(chkc) end
	if chk == 0 then
		return Duel.IsExistingTarget(cm.filter, tp, LOCATION_MZONE, 0, 1, nil) and
			Duel.IsExistingMatchingCard(cm.filter2, tp, LOCATION_DECK, 0, 1, nil, e:GetHandler(), e, tp)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
	local g = Duel.SelectTarget(tp, cm.filter, tp, LOCATION_MZONE, 0, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local g = Duel.SelectMatchingCard(tp, cm.filter2, tp, LOCATION_DECK, 0, 1, 1, nil, tc, e, tp)
	if #g > 0 then
		local sc = g:GetFirst()
		if Duel.SpecialSummonStep(sc, 0, tp, tp, false, false, POS_FACEUP) then
			-- 效果无效
			local e1 = Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT + RESETS_STANDARD)
			sc:RegisterEffect(e1)
			local e2 = e1:Clone()
			e2:SetCode(EFFECT_DISABLE)
			sc:RegisterEffect(e2)
		end
		Duel.SpecialSummonComplete()
	end
end

function cm.condition2(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and
		(c:IsPreviousLocation(LOCATION_ONFIELD) or (r & REASON_EFFECT ~= 0 and re and re:GetHandler():IsSetCard(0x3e11)))
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.GetFieldGroupCount(tp, LOCATION_HAND + LOCATION_ONFIELD, 0) >= 1 end
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_HAND + LOCATION_ONFIELD)
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local g = Duel.SelectMatchingCard(tp, Card.IsAbleToGrave, tp, LOCATION_HAND + LOCATION_ONFIELD, 0, 1, 2, nil)
	if #g > 0 then
		local ct = Duel.SendtoGrave(g, REASON_EFFECT)
		-- 那之中包含对方怪兽的场合，自己抽2张
		local og = g:Filter(Card.IsControler, nil, 1 - tp)
		if #og > 0 and ct > 0 then
			Duel.Draw(tp, 2, REASON_EFFECT)
		end
	end
end

-- 新① 代价：原本持有者是对方的怪兽
function cm.ownerfilter(c, tp)
	return c:GetOwner() ~= tp and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end

function cm.cost1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(cm.ownerfilter, tp, LOCATION_MZONE, 0, 1, nil, tp)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g = Duel.SelectMatchingCard(tp, cm.ownerfilter, tp, LOCATION_MZONE, 0, 1, 1, nil, tp)
	Duel.SendtoGrave(g, REASON_COST)
end

-- 新① 目标：选场上1张卡
function cm.tg1b(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsOnField() end
	if chk == 0 then
		return Duel.IsExistingTarget(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)
		-- and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, nil, e, 0, tp,
		-- 	false, false)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g = Duel.SelectTarget(tp, aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, 1, 0, 0)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, LOCATION_GRAVE)
end

-- 新① 操作：送墓→从墓地特召→如果是对方怪兽则无效+0攻防+素材限制
function cm.op1b(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if Duel.SendtoGrave(tc, REASON_EFFECT) == 0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, Card.IsCanBeSpecialSummoned, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, 1, nil, e,
		0, tp, false, false)
	if #g == 0 then return end
	local sc = g:GetFirst()
	if Duel.SpecialSummonStep(sc, 0, tp, tp, false, false, POS_FACEUP) then
		if sc:GetOwner() ~= tp then
			-- 效果无效
			local e1 = Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT + RESETS_STANDARD)
			sc:RegisterEffect(e1)
			local e1b = e1:Clone()
			e1b:SetCode(EFFECT_DISABLE_EFFECT)
			sc:RegisterEffect(e1b)
			-- 攻击力·守备力变成0
			local e2 = Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_ATTACK_FINAL)
			e2:SetValue(0)
			e2:SetReset(RESET_EVENT + RESETS_STANDARD)
			sc:RegisterEffect(e2)
			local e2b = e2:Clone()
			e2b:SetCode(EFFECT_SET_DEFENSE_FINAL)
			sc:RegisterEffect(e2b)
			-- 不能作为融合·同调·超量·连接召唤的素材
			local e3 = Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
			e3:SetValue(1)
			e3:SetReset(RESET_EVENT + RESETS_STANDARD)
			sc:RegisterEffect(e3)
			local e3b = e3:Clone()
			e3b:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			sc:RegisterEffect(e3b)
			local e3c = e3:Clone()
			e3c:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
			sc:RegisterEffect(e3c)
			local e3d = e3:Clone()
			e3d:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			sc:RegisterEffect(e3d)
		end
	end
	Duel.SpecialSummonComplete()
end

-- 新② 代价：除外自身和其他1张卡
function cm.cost2b(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then
		return e:GetHandler():IsAbleToRemove()
		-- Duel.IsExistingMatchingCard(Card.IsAbleToRemove, tp, LOCATION_GRAVE, 0, 1, e:GetHandler())
	end
	-- local g = Duel.SelectMatchingCard(tp, Card.IsAbleToRemove, tp, LOCATION_GRAVE, 0, 1, 1, e:GetHandler())
	-- g:AddCard(e:GetHandler())
	Duel.Remove(c, POS_FACEUP, REASON_COST)
end

-- 新② 目标：卡组有「大墓」卡
function cm.tg2b(e, tp, eg, ep, ev, re, r, rp, chk)
	local g = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, LOCATION_GRAVE, 0, e:GetHandler())
	if chk == 0 then
		return Duel.IsExistingMatchingCard(cm.desfilter, tp, LOCATION_DECK, 0, 1, nil) and #g > 0
	end
	Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, 0, 0)
	Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 1, tp, LOCATION_DECK)
end

function cm.desfilter(c)
	return c:IsSetCard(0x3e11) and c:IsAbleToGrave()
end

-- 新② 操作：从卡组选1张「大墓」卡送墓
function cm.op2b(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local g = Duel.SelectMatchingCard(tp, Card.IsAbleToRemove, tp, LOCATION_GRAVE, 0, 1, 1, e:GetHandler())
	Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g = Duel.SelectMatchingCard(tp, cm.desfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoGrave(g, REASON_EFFECT)
	end
end
