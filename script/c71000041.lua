--大墓之帝王
-- 卡片类型：怪兽卡, 效果, 融合
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- 「大墓」怪兽×3
	-- 这个卡名的①②效果1回合各能使用1次。
	c:EnableReviveLimit()
	-- 融合召唤条件
	aux.AddFusionProcMix(c, true, true, cm.ffilter, cm.ffilter, cm.ffilter)

	-- ①：有卡被送去自己墓地的场合才能发动。从自己墓地选1只怪兽特殊召唤，或者选1张「大墓」魔法·陷阱卡盖放到自己场上。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1, m + 1)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(cm.condition1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：有卡被除外的场合才能发动。从对方卡组上面把3张卡送去墓地。送去墓地的卡有怪兽的场合，可以选那之中的1只怪兽，从对方墓地效果无效并特殊召唤到自己场上。那只怪兽不能作为融合·同调·超量·连接召唤的素材。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_TOGRAVE + CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1, m + 2)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(cm.condition2)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

function cm.ffilter(c, fc, sumtype, tp)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_MONSTER)
end

function cm.condition1(e, tp, eg, ep, ev, re, r, rp)
	return eg:IsExists(Card.IsControler, 1, nil, tp)
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	local b1 = Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
		Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned, tp, LOCATION_GRAVE, 0, 1, nil, e, 0, tp, false, false)
	local b2 = Duel.IsExistingMatchingCard(cm.filter, tp, LOCATION_GRAVE, 0, 1, nil)

	if chk == 0 then return b1 or b2 end

	local off = 1
	local ops = {}
	local opval = {}

	if b1 then
		ops[off] = aux.Stringid(m, 2)
		opval[off - 1] = 1 -- 只发动特殊召唤效果
		off = off + 1
	end
	if b2 then
		ops[off] = aux.Stringid(m, 3)
		opval[off - 1] = 2 -- 只发动盖放魔法陷阱效果
		off = off + 1
	end

	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EFFECT)
	local op = Duel.SelectOption(tp, table.unpack(ops))
	local opt = opval[op]

	e:SetLabel(opt)

	-- 设置操作信息
	if opt == 1 then
		Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
	else
		Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, nil, 1, tp, LOCATION_GRAVE)
	end
end

function cm.filter(c)
	return c:IsSetCard(0x3e11) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:IsSSetable()
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local opt = e:GetLabel()
	if opt == 1 then
		-- 特殊召唤效果
		if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
			local g = Duel.SelectMatchingCard(tp, Card.IsCanBeSpecialSummoned, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, 0, tp,
				false, false)
			if #g > 0 then
				Duel.SpecialSummon(g:GetFirst(), 0, tp, tp, false, false, POS_FACEUP)
			end
		end
	else
		-- 盖放魔法陷阱效果
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
		local g = Duel.SelectMatchingCard(tp, cm.filter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
		if #g > 0 then
			Duel.SSet(tp, g:GetFirst())
			Duel.ConfirmCards(1 - tp, g)
		end
	end
end

function cm.condition2(e, tp, eg, ep, ev, re, r, rp)
	return eg:IsExists(Card.IsAbleToRemove, 1, nil)
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK) >= 3 end
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 3, 0, LOCATION_DECK)
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local g = Duel.GetDecktopGroup(1 - tp, 3)
	if #g > 0 then
		Duel.SendtoGrave(g, REASON_EFFECT)
		-- 送去墓地的卡有怪兽的场合，可以选那之中的1只怪兽，从对方墓地效果无效并特殊召唤到自己场上
		local mg = g:Filter(function(c)
			return c:IsType(TYPE_MONSTER)
		end
		, nil)
		if #mg > 0 and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
			if Duel.SelectYesNo(tp, aux.Stringid(m, 4)) then
				Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
				local sg = mg:Select(tp, 1, 1, nil)
				local tc = sg:GetFirst()
				if tc and Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
					-- 效果无效
					local e1 = Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_DISABLE)
					e1:SetReset(RESET_EVENT + RESETS_STANDARD)
					tc:RegisterEffect(e1)
					local e2 = e1:Clone()
					e2:SetCode(EFFECT_DISABLE)
					tc:RegisterEffect(e2)
					-- 不能作为融合·同调·超量·连接召唤的素材
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
			end
		end
	end
end
