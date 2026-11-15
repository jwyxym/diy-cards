--大墓之终焉亡界龙
-- 卡片类型：怪兽卡, 效果, 融合
-- 暗 12星 龙族 4000/4000
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- 「大墓」怪兽5只
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c, cm.ffilter, 5, true)

	-- ①：只要自己场上有对方怪兽存在，这张卡不会成为对方效果的对象。
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cm.con1)
	e1:SetValue(aux.tgoval) -- 只免疫对方的效果
	c:RegisterEffect(e1)

	-- ②：以对方墓地1只怪兽为对象才能发动。那只怪兽效果无效并特殊召唤到自己场上。那只怪兽不能作为融合·同调·超量·连接召唤的素材。这个效果在对方回合也能发动。这个卡名的②效果1回合只能使用1次。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1, m + 2)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(cm.sptg)
	e2:SetOperation(cm.spop)
	c:RegisterEffect(e2)

	-- ③：对方发动墓地的卡的效果时，把自己场上1只对方怪兽送去墓地才能发动。那个发动无效。
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m, 2))
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cm.negcon)
	e3:SetCost(cm.negcost)
	e3:SetOperation(cm.negop)
	c:RegisterEffect(e3)
end

function cm.ffilter(c, fc, sumtype, tp)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_MONSTER)
end

-- 自己场上原本持有者是对方的怪兽
function cm.oppmonfilter(c)
	return c:GetOwner() ~= c:GetControler() and c:IsLocation(LOCATION_MZONE)
end

-- ========== ① 对象抗性 ==========
function cm.con1(e)
	-- 自己场上存在对方怪兽
	return Duel.IsExistingMatchingCard(cm.oppmonfilter, e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil)
end

-- ========== ② 二速苏生 ==========
function cm.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then 
		return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1 - tp) and chkc:IsCanBeSpecialSummoned(e, 0, tp, false, false) 
	end
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
			Duel.IsExistingTarget(Card.IsCanBeSpecialSummoned, tp, 0, LOCATION_GRAVE, 1, nil, e, 0, tp, false, false)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectTarget(tp, Card.IsCanBeSpecialSummoned, tp, 0, LOCATION_GRAVE, 1, 1, nil, e, 0, tp, false, false)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, LOCATION_GRAVE)
end

function cm.spop(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

	if Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
		-- 效果无效
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2 = e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
		
		-- 不能作为融合·同调·超量·连接召唤的素材
		local e3 = Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT + RESETS_STANDARD)
		tc:RegisterEffect(e3)
		local e4 = e3:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		tc:RegisterEffect(e4)
		local e5 = e3:Clone()
		e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		tc:RegisterEffect(e5)
		local e6 = e3:Clone()
		e6:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		tc:RegisterEffect(e6)
	end
	Duel.SpecialSummonComplete()
end

-- ========== ③ 无效墓地效果 ==========
function cm.negcon(e, tp, eg, ep, ev, re, r, rp)
	local loc = Duel.GetChainInfo(ev, CHAININFO_TRIGGERING_LOCATION)
	-- 完美过滤：必须是对方发动的、可无效的、且发动位置严格在墓地的效果
	return rp == 1 - tp 
		and Duel.IsChainNegatable(ev) 
		and loc == LOCATION_GRAVE
end

function cm.negcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(cm.oppmonfilter, tp, LOCATION_MZONE, 0, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g = Duel.SelectMatchingCard(tp, cm.oppmonfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
	Duel.SendtoGrave(g, REASON_COST)
end

function cm.negop(e, tp, eg, ep, ev, re, r, rp)
	Duel.NegateActivation(ev)
end