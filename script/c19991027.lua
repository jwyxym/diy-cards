--爱丽丝，疯狂国度的先知
function c19991027.initial_effect(c)
	c:SetSPSummonOnce(19991027)
	aux.AddCodeList(c,19991026)
	c:EnableReviveLimit()
	--change code
	aux.EnableChangeCode(c,19991003,LOCATION_MZONE)
	--direct attack
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e0)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--immune
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(c19991027.efilter)
	c:RegisterEffect(e2)
	--activate limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,1)
	e3:SetCondition(c19991027.condition)
	e3:SetValue(c19991027.aclimit)
	c:RegisterEffect(e3)
	--cannot attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetCondition(c19991027.condition)
	e4:SetTarget(c19991027.atktg)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_TRIGGER)
	c:RegisterEffect(e5)
end
function c19991027.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
function c19991027.filter(c)
	return c:IsCode(19991003) and c:IsFaceup()
end
function c19991027.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c19991027.filter,tp,LOCATION_SZONE,0,1,e:GetHandler()) or Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,19991003)
end
function c19991027.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():GetBaseAttack()>1000
end
function c19991027.atktg(e,c)
	return c:GetBaseAttack()>1000
end