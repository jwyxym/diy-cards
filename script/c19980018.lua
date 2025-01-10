--
function c19980018.initial_effect(c)
	c:SetUniqueOnField(1,0,19980018)
	--link summon
	aux.AddLinkProcedure(c,c19980018.mfilter,4)
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
	e1:SetCondition(c19980018.condition)
	e1:SetCost(c19980018.cost)
	e1:SetOperation(c19980018.operation)
	c:RegisterEffect(e1)
	--tohand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19980018,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,19980018)
	e3:SetCost(c19980018.thcost)
	e3:SetTarget(c19980018.thtg)
	e3:SetOperation(c19980018.thop)
	c:RegisterEffect(e3)
end
c19980018.has_text_type=TYPE_UNION
function c19980018.mfilter(c)
	return c:IsLevel(11) or c:IsRank(11)
end
function c19980018.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function c19980018.thfilter(c)
	return aux.IsTypeInText(c,TYPE_UNION) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_DECK)) and c:IsAbleToHand()
end
function c19980018.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19980018.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED+LOCATION_GRAVE)
end
function c19980018.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c19980018.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c19980018.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c19980018.filter(c)
	return c:IsType(TYPE_LINK) and c:IsAttack(0) and c:IsLink(4) and (c:IsRace(RACE_DRAGON) or c:IsSetCard(0xb34)) and c:IsAbleToRemoveAsCost()
end
function c19980018.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)*(2/3)))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c19980018.filter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
function c19980018.operation(e,tp,eg,ep,ev,re,r,rp)
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
		e2:SetDescription(aux.Stringid(19980018,1))
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetCountLimit(1)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetLabelObject(e1)
		e2:SetLabel(cid)
		e2:SetOperation(c19980018.rstop)
		c:RegisterEffect(e2)
	end
end
function c19980018.rstop(e,tp,eg,ep,ev,re,r,rp)
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