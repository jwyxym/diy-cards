--侦探：真相看破
--卡密ID: 45205327
--字段代码: 0x1D5C

local s,id=GetID()

function s.initial_effect(c)
	--①效果：反击陷阱（无效并破坏）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end

--①效果条件
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上有7星以上的侦探怪兽
	if not Duel.IsExistingMatchingCard(s.filter7star,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 不是自己的效果
	if ep==tp then return false end
	-- 是魔法·陷阱·怪兽效果的发动
	if not re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) then return false end
	return true
end

function s.filter7star(c)
	return c:IsFaceup() and c:IsSetCard(0x1D5C) and c:IsLevelAbove(7)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		if Duel.NegateEffect(ev) then
			local rc=re:GetHandler()
			if rc and rc:IsRelateToEffect(re) then
				Duel.Destroy(rc,REASON_EFFECT)
			end
		end
	end
end