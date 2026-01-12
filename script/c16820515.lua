--一护一
local s,id=GetID()

function s.initial_effect(c)
	-- 从手卡发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.handcon)
	c:RegisterEffect(e0)

	-- ① 无效并破坏
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end

-- 墓地没有陷阱卡 → 可从手卡发动
function s.handcon(e)
	return not Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,TYPE_TRAP)
end

-- 1星怪兽效果发动时
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and  Duel.IsChainDisablable(ev) and rc:IsLevel(1) 
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	Duel.NegateActivation(ev)
	if rc:IsRelateToEffect(re) then
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
