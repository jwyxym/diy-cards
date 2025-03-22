--大千录 插肋同受
local this,id,ofs=GetID()
function this.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
	local e=Effect.CreateEffect(c)
    e:SetType(EFFECT_TYPE_ACTIVATE)
    e:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e)
    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetCondition(this.damcon)
	e3:SetOperation(this.damop)
	c:RegisterEffect(e3)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id+1)
    e2:SetCost(this.tgcost)
    e2:SetTarget(this.tgtg)
    e2:SetOperation(this.tgop)
    c:RegisterEffect(e2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(this.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
end
function this.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_EFFECT)~=0
end
function this.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,math.floor(ev/2),REASON_EFFECT)
end
function this.cpfilter(c)
    return c:GetType()==TYPE_SPELL and c:IsSetCard(0x3981) and c:IsAbleToGraveAsCost() and c:CheckActivateEffect(true,true,false)~=nil
end
function this.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
    e:SetLabel(1)
    if chk==0 then return true end
end
function this.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(this.cpfilter,tp,LOCATION_DECK,0,1,nil)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,this.cpfilter,tp,LOCATION_DECK,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(true,true,true)
	Duel.SendtoGrave(g,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function this.tgop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if te then
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
	end
end
function this.indtg(e,c)
	return c:IsSetCard(0x3980) and c:IsFaceup()
end
