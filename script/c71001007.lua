--Rei
-- 卡片类型：怪兽卡, 同调, 效果
-- 光 11星 机械族 2500/2500
local cm, m, o = GetID()

function cm.tuner_filter(c)
	return c and c:IsType(TYPE_TUNER) and c:IsType(TYPE_SYNCHRO)
end
function cm.nontuner_filter(c)
	return c and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TUNER)
end

function cm.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c, cm.tuner_filter, cm.nontuner_filter, 1, 2)

	-- ①：对方把怪兽特殊召唤之际，把这张卡除外才能发动。那个无效，那些怪兽破坏。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1, m)
	e1:SetCondition(cm.e1con)
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(cm.e1tg)
	e1:SetOperation(cm.e1op)
	c:RegisterEffect(e1)

	-- ②：只要这张卡在怪兽区域表侧表示存在，对方不能把卡除外。
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0, 1)
	c:RegisterEffect(e2)

	-- ②：对方场上的怪兽的攻击力·守备力下降1000。
	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0, LOCATION_MZONE) -- 【核心修复】改为区域常量 LOCATION_MZONE
	e3:SetValue(-1000)
	c:RegisterEffect(e3)
	local e4 = e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)

	-- ③：场上的这张卡被除外时，若这张卡的同调召唤使用过的一组同调素材怪兽在自己墓地集齐，可以把那一组特殊召唤。
	local e5 = Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(m, 1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_REMOVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_REMOVED)
	e5:SetCountLimit(1, m + 1)
	e5:SetCondition(cm.e5con)
	e5:SetTarget(cm.e5tg)
	e5:SetOperation(cm.e5op)
	c:RegisterEffect(e5)
end

-- ========== ① ==========
function cm.e1con(e, tp, eg, ep, ev, re, r, rp)
	return eg:IsExists(Card.IsControler, 1, nil, 1 - tp)
end

function cm.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return eg:IsExists(Card.IsControler, 1, nil, 1 - tp) and e:GetHandler():IsAbleToRemoveAsCost()
	end
	local g = eg:Filter(Card.IsControler, nil, 1 - tp)
	Duel.SetOperationInfo(0, CATEGORY_NEGATE, g, g:GetCount(), 0, 0)
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, g:GetCount(), 0, 0)
end

function cm.e1op(e, tp, eg, ep, ev, re, r, rp)
	local g = eg:Filter(Card.IsControler, nil, 1 - tp)
	if Duel.NegateSummon(g) > 0 then
		Duel.BreakEffect()
		Duel.Destroy(g, REASON_EFFECT)
	end
end

-- ========== ③ ==========
function cm.e5con(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end

function cm.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		local mg = e:GetHandler():GetMaterial()
		if not mg then return false end
		
		local mat_count = 0
		local all_in_grave = true
		for tc in aux.Next(mg) do
			mat_count = mat_count + 1
			if not tc:IsLocation(LOCATION_GRAVE) then
				all_in_grave = false
			end
		end
		
		if mat_count == 0 or not all_in_grave then return false end
		
		local count = Duel.GetLocationCount(tp, LOCATION_MZONE)
		if not count or count < mat_count then return false end
		
		return true
	end
	
	local mg = e:GetHandler():GetMaterial()
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, mg, mg:GetCount(), 0, 0)
end

function cm.e5op(e, tp, eg, ep, ev, re, r, rp)
	local mg = e:GetHandler():GetMaterial()
	if not mg then return end
	for tc in aux.Next(mg) do
		Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
end