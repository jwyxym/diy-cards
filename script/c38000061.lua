--惑星守卫 暗影支配者
local this,id,ofs=GetID()
function this.initial_effect(c)
    aux.AddSynchroProcedure(c,this.matfilter,aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),2,2)
    c:EnableReviveLimit()
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
    e3:SetCost(this.atkcost)
	e3:SetTarget(this.atktg)
	e3:SetOperation(this.atkop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e4:SetCondition(this.effcon)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetCondition(this.effcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
function this.matfilter(c)
    return c:IsSynchroType(TYPE_SYNCHRO) and c:IsSetCard(0x1380)
end
function this.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.IsPlayerAffectedByEffect(tp,38000071) and Duel.GetFlagEffect(tp,38000071)==0 then
	if chk==0 then return Duel.CheckLPCost(1-tp,1000) end
		Duel.PayLPCost(1-tp,1000)
		Duel.RegisterFlagEffect(tp,38000071,RESET_PHASE+PHASE_END,0,1)
	else
		if chk==0 then return Duel.CheckLPCost(tp,1000) end
		Duel.PayLPCost(tp,1000)
	end
end
function this.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))>0 end
end
function this.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp)))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
function this.effcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
