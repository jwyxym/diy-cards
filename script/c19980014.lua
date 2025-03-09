--
function c19980014.initial_effect(c)
	c:SetUniqueOnField(1,0,19980014)
	--synchro summon
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),3)
	c:EnableReviveLimit()
	--
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_RACE)
	e0:SetRange(LOCATION_MZONE+LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE)
	e0:SetValue(RACE_FISH)
	c:RegisterEffect(e0)
	--copy
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c19980014.condition)
	e1:SetCost(c19980014.cost)
	e1:SetOperation(c19980014.operation)
	c:RegisterEffect(e1)
	--remove
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19980014,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
	e2:SetCondition(c19980014.rmdcon)
	e2:SetTarget(c19980014.rmtarget)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
end
function c19980014.rmdcon(e)
	return Duel.GetLP(e:GetHandlerPlayer())<=333
end
function c19980014.rmtarget(e,c)
	return not c:IsSetCard(0xb34)
end
function c19980014.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function c19980014.filter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevel(11) and (c:IsRace(RACE_MACHINE) or c:IsSetCard(0xb34)) and c:IsAbleToRemoveAsCost()
end
function c19980014.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)*(2/3)))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c19980014.filter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
function c19980014.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	local tg=Duel.GetFirstMatchingCard(c19980014.filter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,nil)
	if c:IsRelateToEffect(e) and c:IsFaceup() and tg then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCode(EFFECT_ADD_CODE)
		e1:SetValue(tc:GetOriginalCode())
		c:RegisterEffect(e1)
		local code=tc:GetOriginalCode()
		local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD)
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(19980014,1))
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetCountLimit(1)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetLabelObject(e1)
		e2:SetLabel(cid)
		e2:SetOperation(c19980014.rstop)
		c:RegisterEffect(e2)
	end
end
function c19980014.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	if cid~=0 then
		c:ResetEffect(cid,RESET_COPY)
		c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	end
	local e1=e:GetLabelObject()
	e1:Reset()
	Duel.HintSelection(Group.FromCards(c))
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end