--
function c19001000.initial_effect(c)
	aux.AddCodeList(c,19000072,19000071,19001000)
	--to hand
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(19001000,1))
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCountLimit(1,19001000+100+EFFECT_COUNT_CODE_DUEL)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCondition(aux.exccon)
	e0:SetCost(aux.bfgcost)
	e0:SetTarget(c19001000.ptg)
	e0:SetOperation(c19001000.pop)
	c:RegisterEffect(e0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19001000,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,19001000+EFFECT_COUNT_CODE_DUEL)
	e1:SetCost(c19001000.cost)
	e1:SetTarget(c19001000.target(EVENT_CHAINING))
	e1:SetOperation(c19001000.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_BATTLE_END,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetTarget(c19001000.target(EVENT_FREE_CHAIN))
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SUMMON)
	e3:SetTarget(c19001000.target(EVENT_SUMMON))
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON)
	e4:SetTarget(c19001000.target(EVENT_FLIP_SUMMON))
	c:RegisterEffect(e4)
	local e5=e1:Clone()
	e5:SetCode(EVENT_SPSUMMON)
	e5:SetTarget(c19001000.target(EVENT_SPSUMMON))
	c:RegisterEffect(e5)
	local e6=e1:Clone()
	e6:SetCode(EVENT_TO_HAND)
	e6:SetTarget(c19001000.target(EVENT_TO_HAND))
	c:RegisterEffect(e6)
	local e7=e1:Clone()
	e7:SetCode(EVENT_ATTACK_ANNOUNCE)
	e7:SetTarget(c19001000.target(EVENT_ATTACK_ANNOUNCE))
	c:RegisterEffect(e7)
end
function c19001000.pfilter(c,tp)
	return not c:IsType(TYPE_MONSTER) and c:IsCode(19000072,19000071)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function c19001000.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(c19001000.pfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
end
function c19001000.pop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c19001000.pfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
function c19001000.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function c19001000.filter(c,event)
	if not (c:GetType()==TYPE_TRAP+TYPE_COUNTER and c:IsAbleToRemoveAsCost() and not c:IsCode(19001000)) then return false end
	local te=c:CheckActivateEffect(false,true,false)
	return te and te:GetCode()==event
end
function c19001000.target(event)
	return  function(e,tp,eg,ep,ev,re,r,rp,chk)
			if chk==0 then
				if e:GetLabel()==0 then return false end
				e:SetLabel(0)
				return Duel.IsExistingMatchingCard(c19001000.filter,tp,LOCATION_GRAVE,0,1,nil,event)
			end
			e:SetLabel(0)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local g=Duel.SelectMatchingCard(tp,c19001000.filter,tp,LOCATION_GRAVE,0,1,1,nil,event)
			local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
			Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)*(2/3)))
			Duel.Remove(g,POS_FACEUP,REASON_COST)
			e:SetProperty(te:GetProperty())
			local tg=te:GetTarget()
			if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
			te:SetLabelObject(e:GetLabelObject())
			e:SetLabelObject(te)
			Duel.ClearOperationInfo(0)
		end
end
function c19001000.operation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end