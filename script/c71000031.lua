--大墓之管理者
-- 卡片类型：怪兽卡, 效果, 融合
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- 「大墓」怪兽×2
	-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
	-- ❶把自己场上包含「大墓」怪兽在内的2只怪兽送去墓地的场合可以特殊召唤。
	-- 这个方法特殊召唤的这个卡名1回合只能有1次。
	-- 这个卡名的①②效果1回合各能使用1次。
	c:EnableReviveLimit()
	-- 融合召唤条件
	aux.AddFusionProcMix(c, true, true, cm.ffilter, cm.ffilter)
	-- 替代特殊召唤方法
	local e0 = Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCountLimit(1, m)
	e0:SetCondition(cm.spcon)
	e0:SetOperation(cm.spop)
	e0:SetValue(SUMMON_TYPE_FUSION)
	c:RegisterEffect(e0)

	-- ①：以对方墓地1张卡为对象才能发动。那张卡除外。那之后，可以从自己或对方墓地把1只怪兽特殊召唤，特殊召唤的是对方怪兽的场合，那只怪兽效果无效，攻击力·守备力变为0，不能作为融合·同调·超量·链接的素材。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_REMOVE + CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1, m + 1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ③：效果发动时，把这张卡送去墓地才能发动。那个效果变成，「选对方墓地1张卡除外。那之后，可以从自己或对方墓地把1只「大墓之管理者」以外的怪兽特殊召唤，特殊召唤的是对方怪兽的场合，那只怪兽效果无效，攻击力·守备力变为0，不能作为融合·同调·超量·链接的素材」。
	-- local e3 = Effect.CreateEffect(c)
	-- e3:SetDescription(aux.Stringid(m, 0))
	-- e3:SetType(EFFECT_TYPE_QUICK_O)
	-- e3:SetCode(EVENT_CHAINING)
	-- e3:SetRange(LOCATION_MZONE)
	-- e3:SetCountLimit(1, m + 3)
	-- e3:SetCost(cm.e3cost)
	-- e3:SetTarget(cm.e3tg)
	-- e3:SetOperation(cm.e3op)
	-- c:RegisterEffect(e3)


	-- ②：这张卡被效果除外的场合，自己场上有对方怪兽存在的场合才能发动。把自己场上1只对方怪兽送去墓地。那之后，从自己的手卡·场上把融合怪兽卡决定的包含「大墓」怪兽的融合素材怪兽送去墓地，把那1只融合怪兽融合召唤。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_TOGRAVE + CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1, m + 2)
	e2:SetCondition(cm.condition2)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

function cm.ffilter(c)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_MONSTER)
end

function cm.spfilter(c, tp)
	return c:IsAbleToGraveAsCost()
end

function cm.spcheck(c, tp, sg)
	return sg:FilterCount(cm.ffilter, nil) >= 1 and
		Duel.GetLocationCountFromEx(tp, tp, sg, c) > 0
end

function cm.spcheck2(sg, c)
	return sg:IsExists(cm.ffilter, 1, nil)
end

function cm.spcon(e, c)
	if c == nil then return true end
	local tp = c:GetControler()
	local g = Duel.GetMatchingGroup(cm.spfilter, tp, LOCATION_MZONE, 0, nil, tp)
	return #g >= 2 and g:IsExists(cm.ffilter, 1, nil)
end

function cm.spop(e, tp, eg, ep, ev, re, r, rp, c)
	local g = Duel.GetMatchingGroup(cm.spfilter, tp, LOCATION_MZONE, 0, nil, tp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local sg = g:SelectSubGroup(tp, cm.spcheck2, false, 2, 2, c)
	if #sg > 0 then
		Duel.SendtoGrave(sg, REASON_COST)
		-- -- 这个方法特殊召唤的这个卡名1回合只能有1次
		-- local e1 = Effect.CreateEffect(c)
		-- e1:SetType(EFFECT_TYPE_FIELD)
		-- e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		-- e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		-- e1:SetTargetRange(1, 0)
		-- e1:SetTarget(cm.splimit)
		-- e1:SetReset(RESET_PHASE + PHASE_END)
		-- Duel.RegisterEffect(e1, tp)
	end
end

function cm.splimit(e, c)
	return c:IsCode(m) and c:IsLocation(LOCATION_EXTRA)
end

function cm.costfilter(c)
	return c:GetOwner() ~= c:GetControler()
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1 - tp) end
	if chk == 0 then return Duel.IsExistingTarget(nil, tp, 0, LOCATION_GRAVE, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local g = Duel.SelectTarget(tp, nil, tp, 0, LOCATION_GRAVE, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, 0, 0)
end

function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc, POS_FACEUP, REASON_EFFECT) > 0 then
		-- 那之后，可以从自己或对方墓地把1只怪兽特殊召唤
		if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, nil, e, 0, tp, false, false) then
			if Duel.SelectYesNo(tp, aux.Stringid(m, 2)) then
				Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
				local g = Duel.SelectMatchingCard(tp, Card.IsCanBeSpecialSummoned, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1,
					1, nil, e, 0, tp, false, false)
				if #g > 0 then
					local sc = g:GetFirst()
					if Duel.SpecialSummonStep(sc, 0, tp, tp, false, false, POS_FACEUP) then
						-- 特殊召唤的是对方怪兽的场合，那只怪兽效果无效，攻击力·守备力变为0，不能作为融合·同调·超量·链接的素材
						if sc:GetOwner() ~= tp then
							-- 效果无效
							local e1 = Effect.CreateEffect(e:GetHandler())
							e1:SetType(EFFECT_TYPE_SINGLE)
							e1:SetCode(EFFECT_DISABLE)
							e1:SetReset(RESET_EVENT + RESETS_STANDARD)
							sc:RegisterEffect(e1)
							local e2 = e1:Clone()
							e2:SetCode(EFFECT_DISABLE)
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
					end
					Duel.SpecialSummonComplete()
				end
			end
		end
	end
end

function cm.e3con(e, tp, eg, ep, ev, re, r, rp)
	return rp == 1 - tp
end

function cm.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c, REASON_COST)
end

function cm.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return true end
end

function cm.e3op(e, tp, eg, ep, ev, re, r, rp)
	local g = Group.CreateGroup()
	Duel.ChangeTargetCard(ev, g)
	Duel.ChangeChainOperation(ev, cm.e3repop)
end

function cm.e3repop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local g = Duel.SelectMatchingCard(tp, nil, tp, 0, LOCATION_GRAVE, 1, 1, nil)
	if #g > 0 then
		Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
		if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
			local sg = Duel.GetMatchingGroup(cm.e3spfilter, tp, LOCATION_GRAVE, LOCATION_GRAVE, nil, e, tp)
			if #sg > 0 and Duel.SelectYesNo(tp, aux.Stringid(m, 2)) then
				Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
				local tg = sg:Select(tp, 1, 1, nil)
				if #tg > 0 then
					local sc = tg:GetFirst()
					if Duel.SpecialSummonStep(sc, 0, tp, tp, false, false, POS_FACEUP) then
						if sc:GetOwner() ~= tp then
							local e1 = Effect.CreateEffect(e:GetHandler())
							e1:SetType(EFFECT_TYPE_SINGLE)
							e1:SetCode(EFFECT_DISABLE)
							e1:SetReset(RESET_EVENT + RESETS_STANDARD)
							sc:RegisterEffect(e1)
							local e2 = e1:Clone()
							e2:SetCode(EFFECT_DISABLE_EFFECT)
							sc:RegisterEffect(e2)
							local e3 = Effect.CreateEffect(e:GetHandler())
							e3:SetType(EFFECT_TYPE_SINGLE)
							e3:SetCode(EFFECT_SET_ATTACK_FINAL)
							e3:SetValue(0)
							e3:SetReset(RESET_EVENT + RESETS_STANDARD)
							sc:RegisterEffect(e3)
							local e4 = e3:Clone()
							e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
							sc:RegisterEffect(e4)
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
					end
					Duel.SpecialSummonComplete()
				end
			end
		end
	end
end

function cm.e3spfilter(c, e, tp)
	return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and not c:IsCode(m)
end

function cm.condition2(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsExistingMatchingCard(cm.costfilter, tp, LOCATION_MZONE, 0, 1, nil) and
		bit.band(r, REASON_EFFECT) ~= 0
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		local chkf = tp
		local mg1 = Duel.GetFusionMaterial(tp)
		if not mg1:IsExists(cm.fusionfilter, 1, nil, e, tp) then return false end
		local res = Duel.IsExistingMatchingCard(cm.xyzfilter, tp, LOCATION_EXTRA, 0, 1, nil, mg1, tp, e)
		if not res then
			local ce = Duel.GetChainMaterial(tp)
			if ce ~= nil then
				local fgroup = ce:GetTarget()
				local mg2 = fgroup(ce, e, tp)
				local mf = ce:GetValue()
				res = Duel.IsExistingMatchingCard(cm.xyzfilter, tp, LOCATION_EXTRA, 0, 1, nil, mg2, tp, e)
			end
		end
		return res and Duel.IsExistingMatchingCard(cm.costfilter, tp, LOCATION_MZONE, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_MZONE)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function cm.fusionfilter(c, e, tp)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial()
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	-- 把自己场上原本持有者为对方的1只怪兽送去墓地
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g = Duel.SelectMatchingCard(tp, cm.costfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
	if #g > 0 and Duel.SendtoGrave(g, REASON_EFFECT) > 0 then
		-- 那之后，从自己的手卡·场上把融合怪兽卡决定的包含「大墓」怪兽的融合素材怪兽送去墓地，把那1只融合怪兽融合召唤。
		local chkf = tp
		local mg1 = Duel.GetFusionMaterial(tp)
		if not mg1:IsExists(cm.fusionfilter, 1, nil, e, tp) then return end
		local sg1 = Duel.GetMatchingGroup(cm.xyzfilter, tp, LOCATION_EXTRA, 0, nil, mg1, tp, e)
		local mg2 = nil
		local sg2 = nil
		local ce = Duel.GetChainMaterial(tp)
		if ce ~= nil then
			local fgroup = ce:GetTarget()
			mg2 = fgroup(ce, e, tp)
			local mf = ce:GetValue()
			sg2 = Duel.GetMatchingGroup(cm.xyzfilter, tp, LOCATION_EXTRA, 0, nil, mg2, tp, e)
		end
		if sg1:GetCount() > 0 or (sg2 ~= nil and sg2:GetCount() > 0) then
			local sg = sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
			local tg = sg:Select(tp, 1, 1, nil)
			local tc = tg:GetFirst()
			if sg1:IsContains(tc) and (sg2 == nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp, ce:GetDescription())) then
				local bx = mg1:FilterSelect(tp, cm.fusionfilter, 1, 1, nil, e, tp):GetFirst()
				if bx == nil then return end
				local mat1 = Duel.SelectFusionMaterial(tp, tc, mg1, bx, chkf)
				tc:SetMaterial(mat1)
				local num = Duel.SendtoGrave(mat1, REASON_EFFECT + REASON_MATERIAL + REASON_FUSION)
				Duel.BreakEffect()
				if num == mat1:GetCount() then
					Duel.SpecialSummon(tc, SUMMON_TYPE_FUSION, tp, tp, false, false, POS_FACEUP)
				end
			else
				local mat2 = Duel.SelectFusionMaterial(tp, tc, mg2, nil, chkf)
				local fop = ce:GetOperation()
				fop(ce, e, tp, tc, mat2)
			end
			tc:CompleteProcedure()
		end
	end
end

function cm.xyzfilter(c, mg, tp, e)
	return c:IsType(TYPE_FUSION) and
		c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, false, false) and c:CheckFusionMaterial(mg, nil, tp)
end
