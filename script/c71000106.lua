--大墓之司祭主
-- 卡片类型：怪兽卡, 效果, 连接
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- 「大墓」怪兽2只以上
	-- 这个卡名的①②效果1回合各能使用1次。
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c, cm.matfilter, 2, 3)

	-- ①：这张卡连接召唤成功的场合才能发动。从自己墓地把1只「大墓」怪兽特殊召唤。那之后，自己场上有对方怪兽的场合，可以再从卡组把1只「大墓」卡送去墓地或除外。这个回合，自己不是不死族怪兽不能从额外卡组特殊召唤。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOGRAVE + CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1, m + 1)
	e1:SetCondition(cm.e1con)
	e1:SetTarget(cm.e1tg)
	e1:SetOperation(cm.e1op)
	c:RegisterEffect(e1)

	-- ②：这张卡被除外的场合才能发动。从自己除外状态把不死族融合怪兽卡决定的融合素材怪兽返回卡组，把那1只融合怪兽从额外卡组融合召唤（这个场合，特殊召唤当作融合召唤）。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_TODECK + CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1, m + 2)
	e2:SetTarget(cm.e2tg2)
	e2:SetOperation(cm.e2op2)
	c:RegisterEffect(e2)
end

function cm.matfilter(c)
	return c:IsSetCard(0x3E11) and c:IsRace(RACE_ZOMBIE)
end

function cm.e1con(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function cm.spfilter(c, e, tp)
	return c:IsSetCard(0x3E11) and c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function cm.tgfilter(c)
	return c:IsSetCard(0x3E11) and (c:IsAbleToGrave() or c:IsAbleToRemove())
end

function cm.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
			and Duel.IsExistingMatchingCard(cm.spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
end

function cm.oppmonfilter(c)
	return c:GetOwner() ~= c:GetControler()
end

function cm.e1op(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, cm.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
	if #g > 0 and Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) > 0 then
		-- 那之后，自己场上有对方怪兽的场合，可以选那只对方怪兽送去墓地
		local g2 = Duel.GetMatchingGroup(cm.oppmonfilter, tp, LOCATION_MZONE, 0, nil)
		if #g2 > 0 then
			-- 询问是否适用“那之后”效果（把对方怪兽送去墓地）
			if Duel.SelectYesNo(tp, aux.Stringid(m, 4)) then
				Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
				local sg2 = g2:Select(tp, 1, 1, nil)
				Duel.SendtoGrave(sg2, REASON_EFFECT)
				-- 可以再从卡组把1张「大墓」卡送去墓地或除外
				if Duel.IsExistingMatchingCard(cm.tgfilter, tp, LOCATION_DECK, 0, 1, nil) then
					if Duel.SelectYesNo(tp, aux.Stringid(m, 2)) then
						Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
						local sg = Duel.SelectMatchingCard(tp, cm.tgfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
						if #sg > 0 then
							if sg:GetFirst():IsAbleToRemove() and Duel.SelectYesNo(tp, aux.Stringid(m, 3)) then
								Duel.Remove(sg, POS_FACEUP, REASON_EFFECT)
							else
								Duel.SendtoGrave(sg, REASON_EFFECT)
							end
						end
					end
				end
			end
		end

		-- 这个回合，自己不是不死族怪兽不能从额外卡组特殊召唤
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
	return not c:IsRace(RACE_ZOMBIE) and c:IsLocation(LOCATION_EXTRA)
end

function cm.filter1(c, e)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end

function cm.filter2(c, e, tp, m, f, chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_ZOMBIE) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, false, false) and c:CheckFusionMaterial(m, nil, chkf)
end

function cm.e2tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	local chkf = tp
	local mg = Duel.GetMatchingGroup(cm.filter1, tp, LOCATION_REMOVED, 0, nil, e)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(cm.filter2, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, mg, nil, chkf)
	end
	Duel.SetOperationInfo(0, CATEGORY_TODECK, mg, 1, tp, LOCATION_REMOVED)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, 0)
end

function cm.e2op2(e, tp, eg, ep, ev, re, r, rp)
	local chkf = tp
	local mg = Duel.GetMatchingGroup(cm.filter1, tp, LOCATION_REMOVED, 0, nil, e)
	local sg = Duel.GetMatchingGroup(cm.filter2, tp, LOCATION_EXTRA, 0, nil, e, tp, mg, nil, chkf)
	if sg:GetCount() > 0 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local tc = sg:Select(tp, 1, 1, nil):GetFirst()
		local mat = Duel.SelectFusionMaterial(tp, tc, mg, nil, chkf)
		tc:SetMaterial(mat)
		Duel.SendtoDeck(mat, nil, SEQ_DECKSHUFFLE, REASON_EFFECT + REASON_MATERIAL + REASON_FUSION)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc, SUMMON_TYPE_FUSION, tp, tp, false, false, POS_FACEUP)
	end
end