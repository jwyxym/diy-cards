--大墓之祭礼者
-- 卡片类型：怪兽卡, 效果, 连接
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- 「大墓」怪兽1只
	-- 这个卡名的①②效果1回合只能使用1次。
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c, cm.lkfilter, 1, 1)

	-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1只「大墓」怪兽特殊召唤。这个效果发动后，这个回合自己不是不死族怪兽不能从卡组特殊召唤。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1, m + 1)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(cm.spcon1)
	e1:SetTarget(cm.sptg1)
	e1:SetOperation(cm.spop1)
	c:RegisterEffect(e1)

	-- ②：这张卡被送去墓地的场合才能发动，从双方卡组上面把2张卡送去墓地。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1, m + 2)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

function cm.lkfilter(c)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_MONSTER)
end

function cm.spcon1(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function cm.spfilter(c, e, tp)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function cm.sptg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
			and Duel.IsExistingMatchingCard(cm.spfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function cm.spop1(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, cm.spfilter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
	if #g > 0 then
		Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
		-- 这个回合自己不是不死族怪兽不能从卡组特殊召唤
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

function cm.splimit(e, c)
	return not c:IsRace(RACE_ZOMBIE) and c:IsLocation(LOCATION_DECK)
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 2, PLAYER_ALL, LOCATION_DECK)
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local g1 = Duel.GetDecktopGroup(tp, 2)
	local g2 = Duel.GetDecktopGroup(1 - tp, 2)
	g1:Merge(g2)
	Duel.SendtoGrave(g1, REASON_EFFECT)
end
