--惑星兽 魔眼龙王
local this,id,ofs=GetID()
function this.initial_effect(c)
    aux.AddSynchroMixProcedure(c,this.matfilter,nil,nil,aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),1,99)
    c:EnableReviveLimit()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(38000071)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id+1)
    e1:SetCost(this.cost)
    e1:SetTarget(this.tg)
    e1:SetOperation(this.op)
    c:RegisterEffect(e1)
end
function this.matfilter(c)
    return c:IsSetCard(0x1380) and c:IsSynchroType(TYPE_SYNCHRO)
end
function this.cpfilter(c)
	return (c:GetType()==TYPE_SPELL or c:GetType()==TYPE_TRAP) and c:IsSetCard(0x380) and c:IsAbleToGraveAsCost()
		and c:CheckActivateEffect(true,true,false)~=nil
end
function this.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if Duel.IsPlayerAffectedByEffect(tp,38000071) and Duel.GetFlagEffect(tp,38000071)==0 then
		if chk==0 then return Duel.CheckLPCost(1-tp,1000) end
		Duel.PayLPCost(1-tp,1000)
		Duel.RegisterFlagEffect(tp,38000071,RESET_PHASE+PHASE_END,0,1)
	else
		if chk==0 then return Duel.CheckLPCost(tp,1000) end
		Duel.PayLPCost(tp,1000)
	end
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
        local b
        if Duel.IsPlayerAffectedByEffect(tp,38000071) and Duel.GetFlagEffect(tp,38000071)==0 then b=Duel.CheckLPCost(1-tp,1000)
        else b=Duel.CheckLPCost(tp,1000) end
		return b and Duel.IsExistingMatchingCard(this.cpfilter,tp,LOCATION_DECK,0,1,nil)
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
function this.op(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if te then
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
	end
end
