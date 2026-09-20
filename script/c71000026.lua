--大墓之招来者
-- 卡片类型：怪兽卡, 效果
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- 这个卡名的①②效果1回合各能使用1次。
	-- ①：从自己场上把1张魔法·陷阱卡送去墓地才能发动。这张卡从手卡特殊召唤。那之后，可以选场上1张魔法·陷阱卡送去墓地。这个回合，自己不是不死族怪兽不能从手卡特殊召唤。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_TOGRAVE + CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
	e1:SetCountLimit(1, m + 1)
	e1:SetCost(cm.cost1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡被效果送去墓地的场合才能发动。以自己或对方墓地1只怪兽为对象。那只怪兽特殊召唤到自己场上，特殊召唤的是对方怪兽的场合，那只怪兽效果无效，攻击力·守备力变为0，不能作为融合·同调·超量·链接的素材。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1, m + 2)
	-- e2:SetCondition(cm.condition2)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

function cm.cost1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(cm.filter, tp, LOCATION_HAND + LOCATION_ONFIELD, 0, 1,
			e:GetHandler())
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g = Duel.SelectMatchingCard(tp, cm.filter, tp, LOCATION_HAND + LOCATION_ONFIELD, 0, 1, 1,
		e:GetHandler())
	Duel.SendtoGrave(g, REASON_COST)
end

function cm.filter(c)
	return c:IsAbleToGraveAsCost()
end

function cm.filter2(c)
	return c:IsAbleToGrave() and c:IsType(TYPE_SPELL + TYPE_TRAP)
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
			c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, LOCATION_HAND)
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) then
		-- 这个回合，自己不是不死族怪兽不能从手卡特殊召唤
		local e1 = Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1, 0)
		e1:SetTarget(cm.splimit)
		e1:SetReset(RESET_PHASE + PHASE_END)
		Duel.RegisterEffect(e1, tp)
		-- 那之后，可以选场上1张魔法·陷阱卡送去墓地
		if Duel.IsExistingMatchingCard(cm.filter2, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil) then
			if Duel.SelectYesNo(tp, aux.Stringid(m, 2)) then
				Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
				local g = Duel.SelectMatchingCard(tp, cm.filter2, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
				if #g > 0 then
					Duel.SendtoGrave(g, REASON_EFFECT)
				end
			end
		end
	end
end

function cm.splimit(e, c)
	return not c:IsRace(RACE_ZOMBIE) and c:IsLocation(LOCATION_HAND)
end

function cm.condition2(e, tp, eg, ep, ev, re, r, rp)
	return r & REASON_EFFECT ~= 0
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
			Duel.IsExistingTarget(Card.IsCanBeSpecialSummoned, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, nil, e, 0, tp,
				false,
				false)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectTarget(tp, Card.IsCanBeSpecialSummoned, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, 1, nil, e, 0, tp,
		false, false)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	if Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
		-- 特殊召唤的是对方怪兽的场合，那只怪兽效果无效，攻击力·守备力变为0，不能作为融合·同调·超量·链接的素材
		if tc:GetOwner() ~= tp then
			-- 效果无效
			local e1 = Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT + RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2 = e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
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
	end
	Duel.SpecialSummonComplete()
end
