--疯狂国度的扑克
function c19991012.initial_effect(c)
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
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE+LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(1)
	e2:SetCondition(c19991012.actcon)
	c:RegisterEffect(e2)
end
function c19991012.actfilter(c,tp)
	return c and c:IsFaceup() and c:IsSetCard(0xb31) and c:IsType(TYPE_MONSTER) and c:IsControler(tp)
end
function c19991012.actcon(e)
	local tp=e:GetHandlerPlayer()
	return c19991012.actfilter(Duel.GetAttacker(),tp) or c19991012.actfilter(Duel.GetAttackTarget(),tp)
end
