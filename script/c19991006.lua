--疯狂国度的茶会
function c19991006.initial_effect(c)
	--change code
	aux.EnableChangeCode(c,19991003,LOCATION_SZONE+LOCATION_GRAVE)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE+LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xb31))
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
