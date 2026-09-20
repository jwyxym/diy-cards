--大墓之祈祷者
-- 卡片类型：怪兽卡, 效果
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- 这个卡名的①②效果1回合各能使用1次。
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只「大墓」怪兽送去墓地。这个回合，自己不是不死族怪兽不能从卡组特殊召唤。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1, m + 1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)
	local e1b = e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)

	-- ②：这张卡被送去墓地的场合才能发动。从自己的卡组选1张「大墓」陷阱卡加入手卡。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1, m + 2)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(cm.filter, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g = Duel.SelectMatchingCard(tp, cm.filter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g > 0 and Duel.SendtoGrave(g, REASON_EFFECT) > 0 then
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1, 0)
		e1:SetTarget(cm.splimit)
		e1:SetReset(RESET_PHASE + PHASE_END)
		Duel.RegisterEffect(e1, tp)
	end
end

function cm.filter(c)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end

function cm.splimit(e, c)
	return not c:IsRace(RACE_ZOMBIE) and c:IsLocation(LOCATION_DECK)
end

function cm.trapfilter(c)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(cm.trapfilter, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, cm.trapfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, g)
	end
end
