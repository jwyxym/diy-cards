--悖论特遣队“阿波罗”
function c37711030.initial_effect(c)
	--to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c37711030.thcon)
	e1:SetTarget(c37711030.thtg)
	e1:SetOperation(c37711030.thop)
	c:RegisterEffect(e1)
	--remove
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37711030,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_F)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c37711030.rmcon)
	e2:SetCost(c37711030.rmcost)
	e2:SetTarget(c37711030.rmtg)
	e2:SetOperation(c37711030.rmop)
	c:RegisterEffect(e2)
end
function c37711030.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp or Duel.IsBattlePhase()--Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
function c37711030.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c37711030.rmfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c37711030.thfilter(c,chk)
	return c:IsSetCard(0x2a9) and c:IsFaceupEx() and c:IsAbleToHand()
end
function c37711030.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,c37711030.rmfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)==0 or not tc:IsLocation(LOCATION_REMOVED) then return end
	if Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(c37711030.thfilter,tp,LOCATION_REMOVED,0,1,nil) and e:GetHandler():GetFlagEffect(37711030)==0 and Duel.SelectYesNo(tp,aux.Stringid(37711030,2)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
		--
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sc=Duel.SelectMatchingCard(tp,c37711030.thfilter,tp,LOCATION_DECK,0,1,1,nil,1):GetFirst()
		if not sc then return end
		Duel.HintSelection(Group.FromCards(sc))
		Duel.SendtoHand(sc,nil,REASON_EFFECT)
		e:GetHandler():RegisterFlagEffect(37711030,RESET_EVENT+RESETS_WITHOUT_TEMP_REMOVE+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(37711030,5))
	end
end
function c37711030.rmcon(e,tp,eg,ep,ev,re,r,rp)
	if ev<2 then return false end
	return rp==Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_PLAYER)
end
function c37711030.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	if Duel.Remove(c,0,REASON_COST+REASON_TEMPORARY)~=0 then
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_CHAIN_END)
		e0:SetReset(RESET_PHASE+PHASE_END)
		e0:SetLabelObject(c)
		e0:SetCountLimit(1)
		e0:SetOperation(c37711030.retop)
		Duel.RegisterEffect(e0,tp)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(37711030,1))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(44401001)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CHAIN)
		c:RegisterEffect(e1)
	end
end
function c37711030.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
function c37711030.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_DECK+LOCATION_GRAVE)
end
function c37711030.rmfilter(c)
	return c:IsSetCard(0x2a9) and c:IsAbleToRemove() and aux.NecroValleyFilter()(c)
end
function c37711030.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c37711030.rmfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
