--
function c20020010.initial_effect(c)
	--LP
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(20020010,0))
	e0:SetCategory(CATEGORY_RECOVER)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e0:SetCountLimit(1,20020010)
	e0:SetTarget(c20020010.rtg)
	e0:SetOperation(c20020010.rop)
	c:RegisterEffect(e0)
	c20020010.sps_effect=e1
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20020010,1))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c20020010.condition)
	e1:SetCost(c20020010.cost)
	e1:SetTarget(c20020010.target)
	e1:SetOperation(c20020010.activate)
	c:RegisterEffect(e1)
	--Effect monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e2)
end
function c20020010.rtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2000)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2000)
end
function c20020010.rop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end
function c20020010.cfilter(c,tp)
	return c:IsSetCard(0xb35) and (c:IsControler(tp) or c:IsFaceup()) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function c20020010.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c20020010.cfilter,1,nil,tp) end
	local sg=Duel.SelectReleaseGroup(tp,c20020010.cfilter,1,1,nil,tp)
	Duel.Release(sg,REASON_COST)
end
function c20020010.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainNegatable(ev) then return false end
	return re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function c20020010.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c20020010.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end