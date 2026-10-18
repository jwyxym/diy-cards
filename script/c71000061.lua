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

	-- ②：这张卡被「大墓」卡的效果送去墓地或被除外的场合才能发动。从自己或对方卡组上面把2张卡送去墓地，那之后，这张卡加入手卡。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_DECKDES + CATEGORY_TOHAND)
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
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsPlayerCanDiscardDeck(tp, 1) end
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local ct = e:GetLabel()
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

--② 目标：自己或对方卡组至少有2张可送，且自身可回手
function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		local can_self = Duel.IsPlayerCanDiscardDeck(tp, 2)
		local can_opp  = Duel.IsPlayerCanDiscardDeck(1 - tp, 2)
		return (can_self or can_opp) and e:GetHandler():IsAbleToHand()
	end
	Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 2, tp, LOCATION_DECK)
	Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 2, 1 - tp, LOCATION_DECK)
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
end

--② 操作：从自己或对方卡组上面把2张卡送去墓地→这张卡加入手卡
function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local can_self = Duel.IsPlayerCanDiscardDeck(tp, 2)
	local can_opp  = Duel.IsPlayerCanDiscardDeck(1 - tp, 2)
	if not can_self and not can_opp then return end
	local send_self
	if can_self and can_opp then
		send_self = Duel.SelectOption(tp, aux.Stringid(m, 2), aux.Stringid(m, 3)) == 0
	else
		send_self = can_self
	end
	local target = send_self and tp or (1 - tp)
	Duel.DiscardDeck(target, 2, REASON_EFFECT)
	if c:IsRelateToEffect(e) and c:IsAbleToHand() then
		Duel.SendtoHand(c, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, c)
	end
end