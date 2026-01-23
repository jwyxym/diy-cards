--梦想的启程
function c20050030.initial_effect(c)
	aux.AddCodeList(c,19000032)
	--Activate
	local e1=aux.AddRitualProcEqual2(c,c20050030.filter,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,nil,nil,true)
	e1:SetCountLimit(1,20050030)
	c:RegisterEffect(e1)
	--protection
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20050030,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c20050030.target)
	e2:SetOperation(c20050030.operation)
	c:RegisterEffect(e2)
end
function c20050030.filter(c)
	return c:IsRace(RACE_ILLUSION) and c:IsFaceupEx()
end
function c20050030.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,20050030)==0 end
end
function c20050030.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetOperation(c20050030.actop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,20050030,RESET_PHASE+PHASE_END,0,1)
end
function c20050030.actop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsCode(19000032) and ep==tp then
		Duel.SetChainLimit(c20050030.chainlm)
	end
end
function c20050030.chainlm(e,rp,tp)
	return tp==rp
end