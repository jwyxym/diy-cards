--悖论特遣队 栖地
function c37711080.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_FZONE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c37711080.regop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c37711080.damcon)
	e2:SetOperation(c37711080.damop)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37711080,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,37711080)
	e3:SetCost(c37711080.thcost)
	e3:SetTarget(c37711080.thtg)
	e3:SetOperation(c37711080.thop)
	c:RegisterEffect(e3)
end
function c37711080.cfilter(c)
	return c:IsSetCard(0x2a9) and c:IsType(TYPE_MONSTER) and c:IsReason(REASON_COST) and c:GetReasonEffect():GetHandler()==c and c:IsFaceup()
end
function c37711080.regop(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not Duel.IsExistingMatchingCard(c37711080.cfilter,tp,LOCATION_REMOVED,0,1,nil) then return end
	e:GetHandler():RegisterFlagEffect(37711080,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1,ev)
end
function c37711080.damcon(e,tp,eg,ep,ev,re,r,rp)
	local res=false
	for _,te in pairs({e:GetHandler():IsHasEffect(EFFECT_FLAG_EFFECT+37711080)}) do
		if te:GetLabel()==ev then res=true end
	end
	return res and Duel.IsExistingMatchingCard(c37711080.cfilter,tp,LOCATION_REMOVED,0,1,nil)
end
function c37711080.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,37711080)
	Duel.Damage(1-tp,500,REASON_EFFECT)
end
function c37711080.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		tc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	end
	if Duel.Remove(tc,0,REASON_COST+REASON_TEMPORARY)~=0 then
		local e0=Effect.CreateEffect(e:GetHandler())
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_CHAIN_ACTIVATING)
		e0:SetReset(RESET_PHASE+PHASE_END)
		e0:SetLabelObject(tc)
		e0:SetCountLimit(1)
		e0:SetOperation(c37711080.retop)
		Duel.RegisterEffect(e0,tp)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(37711080,1))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(44401001)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function c37711080.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
	e:GetLabelObject():IsHasEffect(44401001):Reset()
end
function c37711080.thfilter(c,chk)
	return c:IsSetCard(0x2a9) and c:IsAbleToHand() and (chk==0 or aux.NecroValleyFilter()(c))-- and c:IsFaceupEx() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c37711080.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c37711080.thfilter,tp,LOCATION_DECK,0,1,nil,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c37711080.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,c37711080.thfilter,tp,LOCATION_DECK,0,1,1,nil,1):GetFirst()
	if not tc then return end
	--Duel.HintSelection(Group.FromCards(tc))
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tc)
	--if not tc:IsLocation(LOCATION_HAND) or not Duel.SelectYesNo(tp,aux.Stringid(37711080,2)) then return end
end
