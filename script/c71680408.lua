--进击的四方主
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.rmcost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1000)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function s.filter(c)
	return (c:IsSetCard(0x597) or (c:IsRace(RACE_FAIRY) and c:IsAttack(2600) and c:IsDefense(200) )) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.cfilter(c)
	return c:IsSetCard(0x597)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		if Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then
			local tg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
			local tc=tg:GetFirst()
			while tc do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(2600)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				tc=tg:GetNext()
			end
		end
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED+LOCATION_GRAVE)
end
function s.spfilter(c)
	return c:IsAbleToHand()
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,c)
		if sg:GetCount()>0 then
			Duel.HintSelection(sg)
			if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,e:GetHandler()) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,e:GetHandler())
				if g:GetCount()>0 then
					Duel.HintSelection(g)
					Duel.SendtoHand(g,tp,REASON_EFFECT)
				end
			end
		end
end