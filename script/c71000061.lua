--大墓之轮回
-- 卡片类型：魔法卡, 通常
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：从卡组上面把至多3张卡送去墓地才能发动。从自己除外状态把那个数量的卡返回卡组。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_TOGRAVE + CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, m + 1)
	e1:SetCost(cm.cost1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡被「大墓」卡的效果送去墓地或除外的场合才能发动。从双方卡组上面把2张卡送去墓地，那之后，这张卡加入手卡。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_TOGRAVE + CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1, m + 2)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(cm.condition2)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
	local e3 = e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end

function cm.cost1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetFieldGroupCount(tp, LOCATION_REMOVED, 0) >= 1
	end
	local su = {}
	local num = Duel.GetMatchingGroupCount(nil, tp, LOCATION_DECK, 0, nil)
	if num > 3 then num = 3 end
	local g = Duel.SelectMatchingCard(tp, Card.IsAbleToDeck, tp, LOCATION_REMOVED, 0, 1, num, nil)
	if #g > 0 then
		Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST)
		e:SetLabel(#g)
	end
	-- for i = 1, num do
	-- 	su[i] = i
	-- end
	-- Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	-- local ct = Duel.AnnounceNumber(tp, table.unpack(su))
	-- local g = Duel.GetDecktopGroup(tp, ct)
	-- if #g > 0 then
	-- 	Duel.SendtoGrave(g, REASON_COST)
	-- 	e:SetLabel(ct)
	-- end
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsPlayerCanDiscardDeck(tp, 1) end
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local ct = e:GetLabel()
	-- local g = Duel.SelectMatchingCard(tp, Card.IsAbleToDeck, tp, LOCATION_REMOVED, 0, ct, ct, nil)
	-- if #g > 0 then
	-- 	Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
	-- end
	local g = Duel.GetDecktopGroup(tp, ct)
	if #g > 0 then
		Duel.SendtoGrave(g, REASON_EFFECT)
	end
end

function cm.condition2(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	return re and
		re:GetHandler():IsSetCard(0x3e11) and bit.band(r, REASON_EFFECT) ~= 0
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= 2 and
			Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK) >= 2 and e:GetHandler():IsAbleToHand()
	end
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 2, 0, LOCATION_DECK)
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 2, 1, LOCATION_DECK)
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local g1 = Duel.GetDecktopGroup(tp, 2)
	local g2 = Duel.GetDecktopGroup(1 - tp, 2)
	if #g1 > 0 then
		Duel.SendtoGrave(g1, REASON_EFFECT)
	end
	if #g2 > 0 then
		Duel.SendtoGrave(g2, REASON_EFFECT)
	end
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoHand(e:GetHandler(), nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, e:GetHandler())
	end
end
