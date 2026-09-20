--大墓之终焉亡界龙
-- 卡片类型：怪兽卡, 效果, 融合
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- 「大墓」怪兽2只以上
	-- 这张卡不用「大墓之终焉」的效果不能特殊召唤。
	c:EnableReviveLimit()
	-- 融合召唤条件
	aux.AddFusionProcFunRep2(c, cm.ffilter, 2, 127, true)
	-- 只能用「大墓之终焉」的效果特殊召唤
	-- local e0 = Effect.CreateEffect(c)
	-- e0:SetType(EFFECT_TYPE_SINGLE)
	-- e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
	-- e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- e0:SetValue(cm.splimit)
	-- c:RegisterEffect(e0)

	-- ①：这张卡的原本攻击力·守备力上升作为这张卡的融合素材的怪兽数量×500。
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cm.atkval)
	c:RegisterEffect(e1)
	local e1b = e1:Clone()
	e1b:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e1b)

	-- ②：这张卡的攻击力在2500以上时，只要这张卡在场上表侧表示存在，这张卡不会被效果破坏，对方不能把墓地的效果发动。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetCondition(cm.indescon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e2b = Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD)
	e2b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2b:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2b:SetRange(LOCATION_MZONE)
	e2b:SetTargetRange(0, 1)
	e2b:SetCondition(cm.indescon)
	e2b:SetValue(cm.aclimit)
	c:RegisterEffect(e2b)

	-- ③：这张卡的攻击力1500以上的场合，卡的效果发动时，把这张卡的攻击力降低500才能发动。那个效果无效并破坏，破坏的是怪兽的场合，将其特殊召唤到自己场上。那只怪兽不能作为融合·同调·超量·连接召唤的素材。
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m, 2))
	e3:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY + CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1, m + 2)
	e3:SetCondition(cm.negcon)
	e3:SetCost(cm.negcost)
	e3:SetTarget(cm.negtg)
	e3:SetOperation(cm.negop)
	c:RegisterEffect(e3)

	-- --④：这张卡也当做不死族怪兽使用。
	-- local e4 = Effect.CreateEffect(c)
	-- e4:SetDescription(aux.Stringid(id, 0))
	-- e4:SetType(EFFECT_TYPE_SINGLE)
	-- e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	-- e4:SetCode(EFFECT_ADD_RACE)
	-- e4:SetRange(0xffff)
	-- e4:SetValue(RACE_ZOMBIE)
	-- c:RegisterEffect(e4)
end

function cm.ffilter(c, fc, sumtype, tp)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_MONSTER)
end

function cm.splimit(e, se, sp, st)
	return se:GetHandler():IsCode(71000051)
end

function cm.atkval(e, c)
	return c:GetMaterialCount() * 500
end

function cm.filter(c)
	return c:IsSetCard(0x3e11) and c:IsType(TYPE_MONSTER)
end

function cm.indescon(e)
	return e:GetHandler():GetAttack() >= 2500
end

function cm.aclimit(e, re, tp)
	return re:IsActiveType(TYPE_MONSTER + TYPE_SPELL + TYPE_TRAP) and re:GetHandler():IsLocation(LOCATION_GRAVE)
end

function cm.negcon(e, tp, eg, ep, ev, re, r, rp)
	if e:GetHandler():GetAttack() < 1500 then return false end
	return rp ~= tp and re:IsActiveType(TYPE_MONSTER + TYPE_SPELL + TYPE_TRAP) and Duel.IsChainNegatable(ev)
end

function cm.negcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return e:GetHandler():GetAttack() >= 500 end
	local e1 = Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-500)
	e1:SetReset(RESET_EVENT + RESETS_STANDARD)
	e:GetHandler():RegisterEffect(e1)
end

function cm.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
	end
end

function cm.negop(e, tp, eg, ep, ev, re, r, rp)
	if not Duel.NegateActivation(ev) then return end
	local tc = re:GetHandler()
	if tc:IsRelateToEffect(re) and tc:IsDestructable() then
		if Duel.Destroy(tc, REASON_EFFECT) > 0 and tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsType(TYPE_MONSTER) and tc:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
			if Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
				local e1 = Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT + RESETS_STANDARD)
				tc:RegisterEffect(e1)
				local e1b = e1:Clone()
				e1b:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
				tc:RegisterEffect(e1b)
				local e1c = e1:Clone()
				e1c:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
				tc:RegisterEffect(e1c)
				local e1d = e1:Clone()
				e1d:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
				tc:RegisterEffect(e1d)
			end
			Duel.SpecialSummonComplete()
		end
	end
end
