--疯狂国度的柴郡猫
function c19991002.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--indes
	aux.EnableChangeCode(c,19991003,LOCATION_PZONE)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19991002,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c19991002.spcon)
	c:RegisterEffect(e1)
	--direct attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(c19991002.dircon)
	c:RegisterEffect(e2)
	--atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xb31))
	e3:SetValue(500)
	c:RegisterEffect(e3)
end
function c19991002.filter(c)
	return c:IsCode(19991003) and c:IsFaceup()
end
function c19991002.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c19991002.filter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
function c19991002.dircon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(c19991002.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
