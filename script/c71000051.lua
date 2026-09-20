--大墓之终焉
-- 卡片类型：魔法卡, 通常
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：从对方卡组上面把至多3张卡送去墓地才能发动。根据那之中的怪兽的数量，从卡组选那个数量的「大墓」魔法·陷阱卡盖放到自己的魔法与陷阱区域。自己场上有对方怪兽存在的场合，这个效果盖放的卡在盖放的回合也能发动。这个效果盖放的卡在效果发动后送去墓地。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_DECKDES + CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, m)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡被「大墓」卡的效果送去墓地或被除外的场合才能发动。从双方卡组上面把2张卡送去墓地，那之后，这张卡加入手卡。
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

--① 目标：对方卡组至少有1张卡
function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK) >= 1
	end
	local ct = math.min(3, Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK))
	Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, 1 - tp, ct)
end

function cm.co(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK) >= 1
	end
	local ct = math.min(3, Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK))
	Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, 1 - tp, ct)
end

--① 操作：送墓→数怪兽→盖放S/T→附加自毁/即发效果
function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local ct = math.min(3, Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK))
	if ct <= 0 then return end
	Duel.DiscardDeck(1 - tp, ct, REASON_EFFECT)
	local g = Duel.GetOperatedGroup()
	-- local monster_count = g:FilterCount(Card.IsType, nil, TYPE_MONSTER)
	-- if monster_count <= 0 then return end
	-- 从卡组选「大墓」魔法·陷阱卡盖放
	local deck_g = Duel.GetMatchingGroup(cm.setfilter, tp, LOCATION_DECK, 0, nil)
	if #deck_g == 0 then return end
	-- local set_ct = math.min(monster_count, Duel.GetLocationCount(tp, LOCATION_SZONE))
	-- if set_ct <= 0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
	local sg = deck_g:Select(tp, 1, 1, nil)
	if #sg == 0 then return end
	Duel.SSet(tp, sg)
	-- 自己场上有对方怪兽存在的场合，盖放的卡在盖放的回合也能发动
	-- local has_opponent_monster = Duel.IsExistingMatchingCard(
	-- 	function(c) return c:GetOwner() == 1 - tp end, tp, LOCATION_MZONE, 0, 1, nil)
	-- if has_opponent_monster then
	for tc in aux.Next(sg) do
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD)
		e1:SetCondition(function()
			return Duel.IsExistingMatchingCard(
				function(c) return c:GetOwner() == 1 - tp end, tp, LOCATION_MZONE, 0, 1, nil)
		end)
		tc:RegisterEffect(e1)
		local e2 = e1:Clone()
		e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		tc:RegisterEffect(e2)
		-- end
	end
	-- 盖放的卡在效果发动后送去墓地
	for tc in aux.Next(sg) do
		local e2 = Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVED)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_SET_AVAILABLE)
		e2:SetCondition(cm.selfdestcon)
		e2:SetOperation(cm.selfdestop)
		e2:SetRange(LOCATION_SZONE)
		e2:SetReset(RESET_EVENT + RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end

function cm.setfilter(c)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsSSetable()
end

-- 自毁条件：链解决的卡是本卡自身
function cm.selfdestcon(e, tp, eg, ep, ev, re, r, rp)
	return re:GetHandler() == e:GetHandler() and not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end

-- 自毁操作：送入墓地
function cm.selfdestop(e, tp, eg, ep, ev, re, r, rp)
	Duel.SendtoGrave(e:GetHandler(), REASON_EFFECT)
	e:Reset()
end

--② 条件：被「大墓」卡的效果送去墓地或除外
function cm.condition2(e, tp, eg, ep, ev, re, r, rp)
	return re and re:GetHandler():IsSetCard(0x3e11)
end

--② 目标：双方卡组有足够卡，且自身可回手
function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsPlayerCanDiscardDeck(tp, 2) and Duel.IsPlayerCanDiscardDeck(1 - tp, 2) and
			e:GetHandler():IsAbleToHand()
	end
	Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, tp, 2)
	Duel.SetOperationInfo(0, CATEGORY_DECKDES, nil, 0, 1 - tp, 2)
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
end

--② 操作：双方各送2张→回手
function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	if not Duel.IsPlayerCanDiscardDeck(tp, 2) or not Duel.IsPlayerCanDiscardDeck(1 - tp, 2) then return end
	Duel.DiscardDeck(tp, 2, REASON_EFFECT)
	Duel.DiscardDeck(1 - tp, 2, REASON_EFFECT)
	local c = e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, c)
	end
end
