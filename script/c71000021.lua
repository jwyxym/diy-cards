--大墓之掘墓者
-- 卡片类型：怪兽卡, 效果
-- 暗 6星 不死族 2000/1800
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合才能发动。这张卡从手卡·墓地特殊召唤。那之后，可以把自己手卡·场上1张卡送去墓地，从对方墓地把1只怪兽效果无效并特殊召唤到自己场上，攻击力·守备力变为0，不能作为融合·同调·超量·链接的素材。这个效果发动后，这个回合自己不是「大墓」怪兽不能从手卡·卡组·额外卡组特殊召唤。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
	e1:SetCountLimit(1, m + 1)
	-- 去掉了 e1:SetCost(cm.cost1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡被效果送去墓地的场合，以自己墓地1张「大墓」魔法卡为对象才能发动。那张卡盖放到自己场上。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
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
		
		-- 2. 那之后，可以把自己手卡·场上1张卡送去墓地，从对方墓地把1只怪兽特召
		local can_send = Duel.IsExistingMatchingCard(Card.IsAbleToGrave, tp, LOCATION_HAND + LOCATION_ONFIELD, 0, 1, nil)
		local can_sp = Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
			Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned, tp, 0, LOCATION_GRAVE, 1, nil, e, 0, tp, false, false)
			
		if can_send and can_sp and Duel.SelectYesNo(tp, aux.Stringid(m, 2)) then
			Duel.BreakEffect()
			
			-- 选1张卡送去墓地
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
			local g = Duel.SelectMatchingCard(tp, Card.IsAbleToGrave, tp, LOCATION_HAND + LOCATION_ONFIELD, 0, 1, 1, nil)
			if #g > 0 then
				Duel.SendtoGrave(g, REASON_EFFECT)
				Duel.BreakEffect()
				
				-- 从对方墓地选1只怪兽特召
				Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
				local sg = Duel.SelectMatchingCard(tp, Card.IsCanBeSpecialSummoned, tp, 0, LOCATION_GRAVE, 1, 1, nil, e, 0, tp, false, false)
				if #sg > 0 then
					local sc = sg:GetFirst()
					if Duel.SpecialSummonStep(sc, 0, tp, tp, false, false, POS_FACEUP) then
						-- 效果无效
						local e1 = Effect.CreateEffect(e:GetHandler())
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetCode(EFFECT_DISABLE)
						e1:SetReset(RESET_EVENT + RESETS_STANDARD)
						sc:RegisterEffect(e1)
						local e2 = e1:Clone()
						e2:SetCode(EFFECT_DISABLE_EFFECT) -- 修正了原代码错写成两次 DISABLE 的问题
						sc:RegisterEffect(e2)
						
						-- 攻击力·守备力变为0
						local e3 = Effect.CreateEffect(e:GetHandler())
						e3:SetType(EFFECT_TYPE_SINGLE)
						e3:SetCode(EFFECT_SET_ATTACK_FINAL)
						e3:SetValue(0)
						e3:SetReset(RESET_EVENT + RESETS_STANDARD)
						sc:RegisterEffect(e3)
						local e4 = e3:Clone()
						e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
						sc:RegisterEffect(e4)
						
						-- 不能作为融合·同调·超量·链接的素材
						local e5 = Effect.CreateEffect(e:GetHandler())
						e5:SetType(EFFECT_TYPE_SINGLE)
						e5:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
						e5:SetValue(1)
						e5:SetReset(RESET_EVENT + RESETS_STANDARD)
						sc:RegisterEffect(e5)
						local e6 = e5:Clone()
						e6:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
						sc:RegisterEffect(e6)
						local e7 = e5:Clone()
						e7:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
						sc:RegisterEffect(e7)
						local e8 = e5:Clone()
						e8:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
						sc:RegisterEffect(e8)
					end
					Duel.SpecialSummonComplete()
				end
			end
		end
		
		-- 3. 这个效果发动后，这个回合自己不是「大墓」怪兽不能从手卡·卡组·额外卡组特殊召唤
		local e9 = Effect.CreateEffect(c)
		e9:SetType(EFFECT_TYPE_FIELD)
		e9:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e9:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e9:SetTargetRange(1, 0)
		e9:SetTarget(cm.splimit)
		e9:SetReset(RESET_PHASE + PHASE_END)
		Duel.RegisterEffect(e9, tp)
	end
end

-- 【修改】特召限制：必须是「大墓」怪兽才能从 手卡·卡组·额外卡组 特召
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

-- ②效果过滤：自己墓地1张「大墓」魔法卡
function cm.filter(c)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end