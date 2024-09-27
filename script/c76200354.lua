--圣剑遥远的梦之余音
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCountLimit(1,id)
    e0:SetCondition(this.acon)
    e0:SetTarget(this.atg)
    e0:SetOperation(this.aop)
    c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id+1)
    e1:SetCost(aux.bfgcost)
	e1:SetTarget(this.settg)
	e1:SetOperation(this.setop)
	c:RegisterEffect(e1)
end
function this.afilter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_SPELLCASTER)
end
function this.acon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(this.afilter,tp,LOCATION_MZONE,0,1,nil)
end
function this.atg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function this.aop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
    for tc in aux.Next(g) do
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(ATTRIBUTE_LIGHT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		tc:RegisterEffect(e1)
    end
end
function this.setfilter(c)
	return c:IsCode(76200357) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function this.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(this.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function this.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,this.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end
