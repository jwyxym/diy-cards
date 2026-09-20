--大墓之呼唤者
-- 卡片类型：怪兽卡, 效果
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- 这个卡名的①②效果1回合各能使用1次。
	-- ①：这张卡召唤·特殊召唤成功的场合，把一张手卡送去墓地才能发动。从对方墓地把1只怪兽效果无效并特殊召唤到自己场上，攻击力·守备力变为0，不能作为融合·同调·超量·链接的素材。这个回合，自己不是不死族怪兽不能从额外卡组特殊召唤。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_TOGRAVE + CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1, m + 1)
	e1:SetCost(cm.cost1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)
	local e1b = e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)

	-- ②：这张卡被送去墓地的场合才能发动。从自己的卡组选1只「大墓」怪兽加入手卡。
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

function cm.cost1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost, tp, LOCATION_HAND, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g = Duel.SelectMatchingCard(tp, Card.IsAbleToGraveAsCost, tp, LOCATION_HAND, 0, 1, 1, nil)
	Duel.SendtoGrave(g, REASON_COST)
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
			Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned, tp, 0, LOCATION_GRAVE, 1, nil, e, 0, tp, false,
				false)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, LOCATION_GRAVE)
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, Card.IsCanBeSpecialSummoned, tp, 0, LOCATION_GRAVE, 1, 1, nil, e, 0, tp, false,
		false)
	if #g > 0 then
		local tc = g:GetFirst()
		if Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
			-- 效果无效
			local e1 = Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT + RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2 = e1:Clone()
			e2:SetCode(EFFECT_DISABLE)
			tc:RegisterEffect(e2)
			-- 攻击力·守备力变为0
			local e3 = Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_SET_ATTACK_FINAL)
			e3:SetValue(0)
			e3:SetReset(RESET_EVENT + RESETS_STANDARD)
			tc:RegisterEffect(e3)
			local e4 = e3:Clone()
			e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
			tc:RegisterEffect(e4)
			-- 不能作为融合·同调·超量·链接的素材
			local e5 = Effect.CreateEffect(e:GetHandler())
			e5:SetType(EFFECT_TYPE_SINGLE)
			e5:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
			e5:SetValue(1)
			e5:SetReset(RESET_EVENT + RESETS_STANDARD)
			tc:RegisterEffect(e5)
			local e6 = e5:Clone()
			e6:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			tc:RegisterEffect(e6)
			local e7 = e5:Clone()
			e7:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
			tc:RegisterEffect(e7)
			local e8 = e5:Clone()
			e8:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			tc:RegisterEffect(e8)
		end
		Duel.SpecialSummonComplete()
		-- 这个回合，自己不是不死族怪兽不能从额外卡组特殊召唤
		local e6 = Effect.CreateEffect(e:GetHandler())
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e6:SetTargetRange(1, 0)
		e6:SetTarget(cm.splimit)
		e6:SetReset(RESET_PHASE + PHASE_END)
		Duel.RegisterEffect(e6, tp)
	end
end

function cm.splimit(e, c)
	return not c:IsRace(RACE_ZOMBIE) and c:IsLocation(LOCATION_EXTRA)
end

function cm.filter(c)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(cm.filter, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, cm.filter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, g)
	end
end
