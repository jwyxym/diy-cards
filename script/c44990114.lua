--伊瑟拉之泪
local s,id=GetID()
function s.initial_effect(c)
	-- 记述标记
	aux.AddCodeList(c,44990100)

	-- ①效果：无效发动并除外
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)

	-- ②效果：结束阶段从墓地盖放
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end

-- 检查自己场上是否有「伊瑟拉」超量怪兽
function s.IsYseraXyz(tp)
	return Duel.IsExistingMatchingCard(function(c)
		return c:IsFaceup() and c:IsSetCard(0xcf1) and c:IsType(TYPE_XYZ)
	end,tp,LOCATION_MZONE,0,1,nil)
end

-- 检查自己场上是否有「伊瑟拉」怪兽（卡名）
function s.IsYseraOnField(tp)
	return Duel.IsExistingMatchingCard(function(c)
		return c:IsFaceup() and c:IsCode(44990100) and c:IsType(TYPE_MONSTER)
	end,tp,LOCATION_MZONE,0,1,nil)
end

-- ①效果条件
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 then return false end
	if not s.IsYseraXyz(tp) then return false end
	return Duel.IsChainNegatable(ev)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsActiveType(TYPE_SPELL) or re:IsActiveType(TYPE_TRAP))
end

-- ①效果目标（设置互斥标志）
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

-- ①效果处理（无效发动并除外）
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		local tc = re:GetHandler()
		if tc and tc:IsRelateToEffect(re) then
			Duel.Remove(tc, POS_FACEUP, REASON_EFFECT)
		end
	end
end

-- ②效果条件
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 then return false end
	return s.IsYseraOnField(tp)
end

-- ②效果目标（设置标志）
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

-- ②效果处理（盖放）
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.SSet(tp,c)
	end
end