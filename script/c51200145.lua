--妖刀姬-赤影
function c51200145.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunFunRep(c,c51200145.ffilter1,c51200145.ffilter2,3,67,true,true)
	--特招限制
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	--不能作为融合素材
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--抗性
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e2=e3:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	--攻击力提升
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(c51200145.atkval)
	c:RegisterEffect(e4)
	--多次攻击
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(51200145,0))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	e5:SetCondition(c51200145.atcon)
	e5:SetCost(c51200145.atcost)
	e5:SetOperation(c51200145.atop)
	c:RegisterEffect(e5)
end
	function c51200145.ffilter1(c)
	return c:IsFusionSetCard(0x65d) and c:IsOnField()
end
	function c51200145.ffilter2(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x65d) and (not sg or not sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode()))
end
	function c51200145.indcon(e)
	return e:GetHandler():IsAttackPos()
end
	function c51200145.atkfilter(c)
	return c:IsLocation(LOCATION_REMOVED) and c:IsType(TYPE_MONSTER)
end
	function c51200145.atkval(e)
	return Duel.GetMatchingGroupCount(c51200145.atkfilter,e:GetHandlerPlayer(),LOCATION_REMOVED,LOCATION_REMOVED,nil)*200
end
	function c51200145.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetAttacker()==c and aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and c:IsChainAttackable(0)
end
function c51200145.atfilter(c)
	return c:IsSetCard(0x65d) and c:IsAbleToRemoveAsCost()
end
	function c51200145.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c51200145.atfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c51200145.atfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,2,2,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
	function c51200145.atop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChainAttack()
end