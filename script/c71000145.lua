--石之世界的杰诺
-- 卡片类型：怪兽卡, 效果
-- 地 3星 魔法师族 1200/1200
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组·墓地把1张「石之世界的复活药剂」加入手卡。那之后，这张卡变成里侧守备表示。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1, m)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)
	local e1b = e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)

	-- ②：这张卡在墓地存在的场合，自己场上有「石之世界的斯坦利」存在的场合才能发动。这张卡加入手卡。自己场上有「石之世界的石神千空」存在的场合，也能不加入手卡特殊召唤。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1, m + 1)
	e2:SetCondition(cm.con2)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

-- ========== ① ==========
-- ① 目标：卡组·墓地有「石之世界的复活药剂」(71000126)
function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(cm.thfilter1, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

-- ① 操作：检索 → 变成里侧守备表示
function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, cm.thfilter1, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, g)
		Duel.ShuffleHand(tp)
	end
	-- 那之后，这张卡变成里侧守备表示
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) then
		Duel.ChangePosition(c, POS_FACEDOWN_DEFENSE)
	end
end

-- 「石之世界的复活药剂」过滤
function cm.thfilter1(c)
	return c:IsCode(71000126) and c:IsAbleToHand()
end

-- ========== ② ==========
-- ② 条件：自己场上有表侧表示的「石之世界的斯坦利」(71000151)
function cm.con2(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsExistingMatchingCard(cm.filterStanley, tp, LOCATION_MZONE, 0, 1, nil)
end

function cm.filterStanley(c)
	return c:IsCode(71000151) and c:IsFaceup()
end

-- ② 目标
function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return e:GetHandler():IsAbleToHand() or Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

-- ② 操作：加入手卡 或 特殊召唤（需场上有千空）
function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local hasSenku = Duel.IsExistingMatchingCard(cm.filterSenku, tp, LOCATION_MZONE, 0, 1, nil)
	
	-- 如果场上有千空(71000120)，且怪兽区有空位，询问是否特召
	if hasSenku and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 
		and Duel.SelectYesNo(tp, aux.Stringid(m, 2)) then
		Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_ATTACK)
	else
		-- 否则加入手卡
		Duel.SendtoHand(c, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, c)
	end
end

function cm.filterSenku(c)
	return c:IsCode(71000120) and c:IsFaceup()
end