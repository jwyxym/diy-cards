--无人知晓的无垢搏动
function c76200513.initial_effect(c)
	aux.AddCodeList(c,76200500)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN) 
	e1:SetCountLimit(1,76200513)
	e1:SetTarget(c76200513.target)
	e1:SetOperation(c76200513.activate)
	c:RegisterEffect(e1) 
	--set
	local e2=Effect.CreateEffect(c)  
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,16200513) 
	e2:SetCondition(c76200513.setcon)
	e2:SetTarget(c76200513.settg)
	e2:SetOperation(c76200513.setop)
	c:RegisterEffect(e2)
end 
function c76200513.tarfil(c,tp) 
	return c:IsFaceup() and aux.IsCodeListed(c,76200500) and c:IsType(TYPE_SYNCHRO) and Duel.IsExistingMatchingCard(c76200513.disfil,tp,0,LOCATION_MZONE,1,nil,c)
end 
function c76200513.disfil(c,sc) 
	return aux.NegateMonsterFilter(c) and c:IsAttackBelow(sc:GetAttack()) 
end 
function c76200513.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c76200513.tarfil,tp,LOCATION_MZONE,0,1,nil) end 
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_MZONE) 
end 
function c76200513.activate(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	local sc=Duel.SelectMatchingCard(tp,c76200513.tarfil,tp,LOCATION_MZONE,0,1,1,nil):GetFirst() 
	if sc then 
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		sc:RegisterEffect(e1)
		local g=Duel.GetMatchingGroup(c76200513.disfil,tp,0,LOCATION_MZONE,nil,sc)
		local tc=g:GetFirst()
		while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
		end  
	end 
end
function c76200513.tckfil(c,tp) 
	return c:IsPreviousControler(tp) and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON) and c:IsReason(REASON_EFFECT) 
end 
function c76200513.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c76200513.tckfil,1,nil,tp)
end  
function c76200513.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function c76200513.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
