--
function c19980012.initial_effect(c)
	c:SetUniqueOnField(1,0,19980012)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsLevel,11),2,true)
	--
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_RACE)
	e0:SetRange(LOCATION_MZONE+LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE)
	e0:SetValue(RACE_FISH)
	c:RegisterEffect(e0)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetDescription(aux.Stringid(19980012,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,19980012)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c19980012.discon)
	e1:SetTarget(c19980012.distg)
	e1:SetOperation(c19980012.disop)
	c:RegisterEffect(e1)
	--copy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c19980012.condition)
	e2:SetCost(c19980012.cost)
	e2:SetOperation(c19980012.operation)
	c:RegisterEffect(e2)
end
function c19980012.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function c19980012.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c19980012.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function c19980012.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function c19980012.filter(c)
	return c:IsType(TYPE_FUSION) and c:IsLevel(11) and (c:IsRace(RACE_ILLUSION) or c:IsSetCard(0xb34)) and c:IsAbleToRemoveAsCost()
end
function c19980012.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)*(2/3)))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c19980012.filter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
function c19980012.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
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
		e2:SetDescription(aux.Stringid(19980012,1))
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetCountLimit(1)
		e2:SetRange(LOCATION_MZONE)
		e2:SetLabelObject(e1)
		e2:SetLabel(cid)
		e2:SetOperation(c19980012.rstop)
		c:RegisterEffect(e2)
	end
end
function c19980012.rstop(e,tp,eg,ep,ev,re,r,rp)
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