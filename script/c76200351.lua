--环抱着你的希望之星
local this,id,ofs=GetID()
function this.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
	local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_SZONE)
    e1:SetCondition(this.con)
	e1:SetTarget(this.desreptg)
	e1:SetValue(this.desrepval)
	e1:SetOperation(this.desrepop)
	c:RegisterEffect(e1)
end
function this.filter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER)
end
function this.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField() and c:IsAttribute(ATTRIBUTE_LIGHT) and not c:IsReason(REASON_REPLACE)
end
function this.desfilter(c,e,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsControler(tp) and c:IsSetCard(0x723) and c:IsType(TYPE_SPELL)
		and c:IsAbleToGrave()
end
function this.con(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(this.filter,tp,LOCATION_MZONE,0,1,nil)
end
function this.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(this.repfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(this.desfilter,tp,LOCATION_SZONE+LOCATION_HAND,0,1,nil,e,tp) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g=Duel.SelectMatchingCard(tp,this.desfilter,tp,LOCATION_SZONE+LOCATION_HAND,0,1,1,nil,e,tp)
		e:SetLabelObject(g:GetFirst())
		return true
	end
	return false
end
function this.desrepval(e,c)
	return this.repfilter(c,e:GetHandlerPlayer())
end
function this.desrepop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local tc=e:GetLabelObject()
	Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REPLACE)
end
