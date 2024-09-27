--惑星守卫 闪光支配者
local this,id,ofs=GetID()
function this.initial_effect(c)
    aux.AddSynchroProcedure(c,this.matfilter,aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),2,2)
    c:EnableReviveLimit()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_LPCOST_CHANGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetValue(this.costchange)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetCondition(this.effcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CHANGE_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(1,0)
    e4:SetCondition(this.effcon)
	e4:SetValue(this.damval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e5)
end
function this.matfilter(c)
    return c:IsSynchroType(TYPE_SYNCHRO) and c:IsSetCard(0x1380)
end
function this.costchange(e,re,rp,val)
	if re and re:GetHandler():IsSetCard(0x380) and (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsType(TYPE_SPELL+TYPE_TRAP) or re:GetHandler():IsType(TYPE_MONSTER)) then
		return 0
	else
		return val
	end
end
function this.effcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
function this.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then return 0 end
	return val
end
