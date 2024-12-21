--尸朽之狂战
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(this.acon)
	e1:SetTarget(this.atg)
	e1:SetOperation(this.aop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(this.op)
	c:RegisterEffect(e2)
end
function this.confilter(c)
	return c:IsSetCard(0x679) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
function this.acon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(this.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function this.atg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b=Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return true end
	local op=0
	if b then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	e:SetLabel(op)
	if op==0 then Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,0,0) end
end
function this.aop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g1=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g2=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
		g1:Merge(g2)
		Duel.Destroy(g1,REASON_EFFECT)
	else
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(this.imlimit)
		e1:SetValue(this.imval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function this.imlimit(e,c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
function this.imval(e,re,rp)
	return rp==1-e:GetHandlerPlayer() and re:GetHandler():IsType(TYPE_MONSTER)
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetOperation(this.lpop1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function this.lpop1(e,tp,eg,ep,ev,re,r,rp)
	local rnum=eg:GetSum(Card.GetBaseAttack)
	Duel.Recover(tp,rnum,REASON_EFFECT)
end
