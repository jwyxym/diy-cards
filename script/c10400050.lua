--大千录
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e=Effect.CreateEffect(c)
    e:SetType(EFFECT_TYPE_ACTIVATE)
    e:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e)
	local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(2,id)
    e2:SetCost(this.tgcost)
    e2:SetTarget(this.tgtg)
    e2:SetOperation(this.tgop)
    c:RegisterEffect(e2)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(this.etarget)
	e2:SetValue(this.efilter)
	c:RegisterEffect(e2)
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
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,500)
end
function this.tgop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if te then
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
	end
	Duel.BreakEffect()
	Duel.Damage(tp,500,REASON_EFFECT)
end
function this.etarget(e,c)
	return c:IsSetCard(0x3980) and c:IsFaceup()
end
function this.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
