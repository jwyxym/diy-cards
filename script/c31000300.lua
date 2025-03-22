--腥红之祖神 布拉德
function c31000300.initial_effect(c)
	c:EnableCounterPermit(0x312)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcMixRep(c,true,true,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_DARK),1,99,c31000300.mfilter1,c31000300.mfilter2,c31000300.mfilter3)
	--counter
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c31000300.ctcon)
	e1:SetTarget(c31000300.cttg)
	e1:SetOperation(c31000300.ctop)
	c:RegisterEffect(e1)
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_SINGLE)
	e11:SetCode(EFFECT_MATERIAL_CHECK)
	e11:SetValue(c31000300.valcheck)
	e11:SetLabelObject(e1)
	c:RegisterEffect(e11)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c31000300.atkval)
	c:RegisterEffect(e2)
	--disable
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetHintTiming(TIMING_DAMAGE_STEP,TIMINGS_CHECK_MONSTER+TIMING_DAMAGE_STEP)
	e3:SetCountLimit(1,31000300)
	e3:SetCost(c31000300.atkcost)
	e3:SetTarget(c31000300.atktg)
	e3:SetOperation(c31000300.atkop)
	c:RegisterEffect(e3)
end
function c31000300.mfilter1(c)
	return c:IsFusionSetCard(0x312) and c:IsFusionType(TYPE_FUSION)
end
function c31000300.mfilter2(c)
	return c:IsFusionSetCard(0x312)
end
function c31000300.mfilter3(c)
	return c:IsFusionSetCard(0x312) and c:IsFusionType(TYPE_FUSION)
end
function c31000300.valcheck(e,c)
	local g=c:GetMaterial()
	e:GetLabelObject():SetLabel(#g)
end
function c31000300.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()>0
end
function c31000300.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	if chk==0 then return c:IsCanAddCounter(0x312,ct) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,ct,0,0x312)
end
function c31000300.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x312,ct)
	end
end
function c31000300.atkval(e,c)
	return Duel.GetCounter(0,1,1,0x312)*200
end
function c31000300.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x312,3,REASON_COST) end
	Duel.RemoveCounter(tp,1,1,0x312,3,REASON_COST)
end
function c31000300.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
end
function c31000300.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=c:GetAttack()
	local g=Duel.GetMatchingGroup(aux.nzatk,tp,0,LOCATION_MZONE,nil)
	local dg=Group.CreateGroup()
	local tc=g:GetFirst()
	while tc do
		local preatk=tc:GetAttack()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if preatk~=0 and tc:IsAttack(0) then dg:AddCard(tc) end
		tc=g:GetNext()
	end
	local ng=dg:Filter(aux.NegateMonsterFilter,nil)
	local nc=ng:GetFirst()
	while nc do
		Duel.NegateRelatedChain(nc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		nc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(RESET_TURN_SET)
		nc:RegisterEffect(e2)
		nc=ng:GetNext()
	end
end