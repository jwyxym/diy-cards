--
function c19990061.initial_effect(c)
	c:SetSPSummonOnce(19990061)
	c:SetUniqueOnField(1,0,19990061)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xb29),3)
	c:EnableReviveLimit()
	--cannot disable spsummon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCondition(c19990061.effcon)
	c:RegisterEffect(e0)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetValue(c19990061.atkval)
	c:RegisterEffect(e1)
	--attackall
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--pierce
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c19990061.target)
	c:RegisterEffect(e3)
end
function c19990061.effcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c19990061.atkfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xb29) and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) and not c:IsCode(19990061)
end
function c19990061.atkval(e,c)
	return Duel.GetMatchingGroupCount(c19990061.atkfilter,c:GetControler(),LOCATION_REMOVED+LOCATION_MZONE+LOCATION_GRAVE,LOCATION_REMOVED+LOCATION_MZONE+LOCATION_GRAVE,nil)*1850
end
function c19990061.target(e,c)
	return c:IsSetCard(0xb29)
end