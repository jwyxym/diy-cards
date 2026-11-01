--大墓之招来者
-- 卡片类型：怪兽卡, 效果
-- 暗 6星 不死族 1900/1900
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合才能发动。这张卡从手卡·墓地特殊召唤。那之后，可以把自己手卡·场上1张卡送去墓地，选场上1张魔法·陷阱卡送去墓地。这个效果发动后，这个回合自己不是「大墓」怪兽不能从手卡·卡组·额外卡组特殊召唤。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
	e1:SetCountLimit(1, m + 1)
	-- 【修改】删除了 e1:SetCost(cm.cost1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡被效果送去墓地的场合才能发动。从自己或对方墓地选1只怪兽在自己场上特殊召唤。特殊召唤的是对方怪兽的场合，那只怪兽效果无效，攻击力·守备力变为0，不能作为融合·同调·超量·链接的素材。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	-- 【修改】去掉了取对象标志 EFFECT_FLAG_CARD_TARGET
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1, m + 2)
	e2:SetCondition(cm.condition2) -- 【恢复】被效果送去墓地的条件
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

-- ========== ① ==========
function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
			c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, c:GetLocation())
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	
	-- 1. 从手卡·墓地特召自身
	if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
		
		-- 2. 那之后，可以把自己手卡·场上1张卡送去墓地，选场上1张魔陷送去墓地
		local can_send = Duel.IsExistingMatchingCard(Card.IsAbleToGrave, tp, LOCATION_HAND + LOCATION_ONFIELD, 0, 1, nil)
		local can_destroy = Duel.IsExistingMatchingCard(cm.filter2, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)
		
		if can_send and can_destroy and Duel.SelectYesNo(tp, aux.Stringid(m, 2)) then
			Duel.BreakEffect()
			-- 选自己手卡·场上1张卡送去墓地
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
			local g = Duel.SelectMatchingCard(tp, Card.IsAbleToGrave, tp, LOCATION_HAND + LOCATION_ONFIELD, 0, 1, 1, nil)
			if #g > 0 then
				Duel.SendtoGrave(g, REASON_EFFECT)
				Duel.BreakEffect()
				
				-- 选场上1张魔法·陷阱卡送去墓地
				Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
				local sg = Duel.SelectMatchingCard(tp, cm.filter2, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
				if #sg > 0 then
					Duel.SendtoGrave(sg, REASON_EFFECT)
				end
			end
		end
		
		-- 3. 这个效果发动后，这个回合自己不是「大墓」怪兽不能从手卡·卡组·额外卡组特殊召唤
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

-- 魔陷卡过滤
function cm.filter2(c)
	return c:IsAbleToGrave() and c:IsType(TYPE_SPELL + TYPE_TRAP)
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

-- 目标：由于不取对象，这里只检查能否特召
function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
			Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, nil, e, 0, tp, false, false)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
end

-- 操作：选怪兽并特召，赋予负面效果
function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	-- 效果处理时，从双方墓地选1只怪兽
	local g = Duel.SelectMatchingCard(tp, Card.IsCanBeSpecialSummoned, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, 1, nil, e, 0, tp, false, false)
	if #g == 0 then return end
	local tc = g:GetFirst()
	
	if Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
		-- 特殊召唤的是对方怪兽的场合，赋予负面效果
		if tc:GetOwner() ~= tp then
			-- 效果无效
			local e1 = Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT + RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2 = e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT) -- 修正了原代码错写成两次 DISABLE 的问题
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