--悖论特遣队“信天翁”
function c37711020.initial_effect(c)
	--to deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c37711020.tdcon)
	e1:SetTarget(c37711020.tdtg)
	e1:SetOperation(c37711020.tdop)
	c:RegisterEffect(e1)
	--remove
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37711020,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_F)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c37711020.rmcon)
	e2:SetCost(c37711020.rmcost)
	e2:SetTarget(c37711020.rmtg)
	e2:SetOperation(c37711020.rmop)
	c:RegisterEffect(e2)
	--
	Duel.AddCustomActivityCounter(37711020,ACTIVITY_CHAIN,c37711020.chainfilter)
end
function c37711020.chainfilter(re,tp,cid)
	return cid<3
end
function c37711020.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp or Duel.IsBattlePhase()--Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
function c37711020.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
end
function c37711020.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,3,nil)
	--if #g==0 or aux.PlaceCardsOnDeckTop(tp,g)==0 then return end
	aux.PlaceCardsOnDeckTop(tp,g)
	if Duel.GetCustomActivityCount(37711020,tp,ACTIVITY_CHAIN)>0 and e:GetHandler():GetFlagEffect(37711020)==0 and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(37711020,2)) then
		Duel.Draw(tp,1,REASON_EFFECT)
		e:GetHandler():RegisterFlagEffect(37711020,RESET_EVENT+RESETS_WITHOUT_TEMP_REMOVE+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(37711020,5))
	end
end
function c37711020.rmcon(e,tp,eg,ep,ev,re,r,rp)
	if ev<2 then return false end
	return rp==Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_PLAYER)
end
function c37711020.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	if Duel.Remove(c,0,REASON_COST+REASON_TEMPORARY)~=0 then
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_CHAIN_END)
		e0:SetReset(RESET_PHASE+PHASE_END)
		e0:SetLabelObject(c)
		e0:SetCountLimit(1)
		e0:SetOperation(c37711020.retop)
		Duel.RegisterEffect(e0,tp)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(37711020,1))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(44401001)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CHAIN)
		c:RegisterEffect(e1)
	end
end
function c37711020.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
function c37711020.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_DECK+LOCATION_GRAVE)
end
function c37711020.rmfilter(c)
	return c:IsSetCard(0x2a9) and c:IsAbleToRemove() and aux.NecroValleyFilter()(c)
end
function c37711020.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c37711020.rmfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
