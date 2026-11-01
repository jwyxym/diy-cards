--大墓之呼唤者
-- 卡片类型：怪兽卡, 效果
-- 暗 3星 不死族 800/800
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从对方墓地把1只怪兽效果无效并特殊召唤到自己场上，攻击力·守备力变为0，不能作为融合·同调·超量·链接的素材。那之后，可以把1张手卡送去墓地。这个效果发动后，这个回合自己不是「大墓」怪兽不能从手卡·卡组·额外卡组特殊召唤。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOGRAVE)
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

	-- ②：这张卡被效果送去墓地的场合才能发动。从自己的卡组选1只「大墓」怪兽加入手卡。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1, m + 2)
	e2:SetCondition(cm.con2) -- 【新增】被效果送去墓地的条件
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

-- ========== ① ==========
-- ① 目标：检查是否有空位及对方墓地是否有可特召的怪兽
function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
			Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned, tp, 0, LOCATION_GRAVE, 1, nil, e, 0, tp, false, false)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, LOCATION_GRAVE)
end

-- ① 操作：特召 -> 赋予无效/0攻守/不能作素材 -> 可选送手卡 -> 赋予特召限制
function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, Card.IsCanBeSpecialSummoned, tp, 0, LOCATION_GRAVE, 1, 1, nil, e, 0, tp, false, false)
	
	if #g > 0 then
		local tc = g:GetFirst()
		if Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
			-- 效果无效（修正了原代码里错写成两次 EFFECT_DISABLE 的问题）
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
		Duel.SpecialSummonComplete()
		
		-- 【修改】那之后，可以把1张手卡送去墓地（选发效果）
		if Duel.IsExistingMatchingCard(Card.IsAbleToGrave, tp, LOCATION_HAND, 0, 1, nil) 
			and Duel.SelectYesNo(tp, aux.Stringid(m, 2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
			local hg = Duel.SelectMatchingCard(tp, Card.IsAbleToGrave, tp, LOCATION_HAND, 0, 1, 1, nil)
			if #hg > 0 then
				Duel.SendtoGrave(hg, REASON_EFFECT)
			end
		end
	end

	-- 【修改】这个效果发动后，这个回合自己不是「大墓」怪兽不能从手卡·卡组·额外卡组特殊召唤
	local e9 = Effect.CreateEffect(e:GetHandler())
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e9:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e9:SetTargetRange(1, 0)
	e9:SetTarget(cm.splimit)
	e9:SetReset(RESET_PHASE + PHASE_END)
	Duel.RegisterEffect(e9, tp)
end

-- 【修改】限制条件：必须是「大墓」怪兽才能从 手卡·卡组·额外卡组 特召
function cm.splimit(e, c, sump, sumtype, sumpos, targetp, se)
	if c:IsLocation(LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA) then
		return not (c:IsSetCard(0x3e11) and c:IsType(TYPE_MONSTER))
	end
	return false
end

-- ========== ② ==========
-- 【新增】被效果送去墓地的条件判断
function cm.con2(e, tp, eg, ep, ev, re, r, rp)
	return bit.band(r, REASON_EFFECT) ~= 0
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
		Duel.ShuffleHand(tp)
	end
end