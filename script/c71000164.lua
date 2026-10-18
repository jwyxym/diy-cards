--石之世界的浅雾幻
-- 卡片类型：怪兽卡, 效果
-- 地 3星 魔法师族 800/1200
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：自己场上有「石之世界的石神千空」存在的场合才能发动，这张卡从手卡往对方场上里侧守备表示特殊召唤。这个效果在对方回合也能发动。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1, m)
	e1:SetCondition(cm.con1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡变成表侧表示的场合发动，这张卡回到原本持有者场上。那之后，这张卡的原本持有者随机确认对方1张手卡，直到回合结束时，对方不能发动那张卡及其同名卡效果。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_CONTROL + CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_FLIP)
	e2:SetCountLimit(1, m + 1)
	e2:SetCondition(cm.con2)  -- 【新增】条件判断
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end

-- ========== ① ==========
function cm.con1(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsExistingMatchingCard(cm.filter1, tp, LOCATION_MZONE, 0, 1, nil)
end
function cm.filter1(c)
	return c:IsCode(71000120) and c:IsFaceup()
end
function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetLocationCount(1 - tp, LOCATION_MZONE) > 0
			and Duel.IsExistingMatchingCard(cm.filter1, tp, LOCATION_MZONE, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, tp, LOCATION_HAND)
end
function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if Duel.GetLocationCount(1 - tp, LOCATION_MZONE) <= 0 then return end
	Duel.SpecialSummon(c, 0, tp, 1 - tp, false, false, POS_FACEDOWN_DEFENSE)
end

-- ========== ② ==========
-- 【核心修复】只有当前控制者不等于原本持有者时才触发（即这张卡在对方场上时）
function cm.con2(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	return c:GetControler() ~= c:GetOwner()
end

function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_CONTROL, e:GetHandler(), 1, 0, 0)
	Duel.SetOperationInfo(0, CATEGORY_HANDES, nil, 1, 1 - tp, LOCATION_HAND)
end

function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local owner = c:GetOwner()

	-- 1. 将控制权归还给原本持有者
	if c:GetControler() ~= owner then
		if Duel.GetLocationCount(owner, LOCATION_MZONE) > 0 then
			Duel.GetControl(c, owner)
		end
	end

	-- 2. 随机确认对方1张手卡
	local opp = 1 - owner
	local g = Duel.GetFieldGroup(opp, LOCATION_HAND, 0)
	if #g > 0 then
		local sg = g:RandomSelect(owner, 1)
		Duel.ConfirmCards(1 - tp, sg)
		Duel.ConfirmCards(owner, sg)
		Duel.ShuffleHand(opp)
		Duel.ShuffleHand(owner)
		
		local tc = sg:GetFirst()
		local code = tc:GetCode()

		-- 3. 直到回合结束时，对方不能发动那张卡及其同名卡效果
		local e1 = Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0, 1)
		e1:SetLabel(code)
		e1:SetTarget(function(e, c) return c and c:IsLocation(LOCATION_HAND) and c:IsCode(e:GetLabel()) end)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE + PHASE_END)
		Duel.RegisterEffect(e1, owner)
	end
end