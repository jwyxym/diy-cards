--身在止境
local this,id,ofs=GetID()
function this.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,1)
    e2:SetCondition(this.accon)
	e2:SetValue(this.aclimit)
	c:RegisterEffect(e2)
end
function this.acfilter(c)
    return c:IsFaceup() and c:IsCode(76200305)
end
function this.accon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(this.acfilter,tp,LOCATION_MZONE,0,1,nil)
end
function this.aclimit(e,re,tp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	local c=re:GetHandler()
	return not c:IsLocation(LOCATION_SZONE)
end
