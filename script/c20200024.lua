--疯狂国度的禁锢
function c20200024.initial_effect(c)
	--change code
	aux.EnableChangeCode(c,20200003,LOCATION_SZONE+LOCATION_GRAVE)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--setcard
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE+LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD+LOCATION_GRAVE,0)
	e2:SetCode(EFFECT_ADD_CODE)
	e2:SetValue(20200003)
	e2:SetTarget(c20200024.indtg)
	c:RegisterEffect(e2)
end
function c20200024.indtg(e,c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and (c:IsSetCard(0xb31) or c:IsSetCard(0xb32))
end