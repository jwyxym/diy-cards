--午夜之翼
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,76200681)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMING_MAIN_END)
	c:RegisterEffect(e0)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--Send to Deck & Draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	--to hand
	local e33=Effect.CreateEffect(c)
	e33:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e33:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e33:SetCode(EVENT_REMOVE)
	e33:SetOperation(s.regop)
	c:RegisterEffect(e33)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_GRAVE_ACTION)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,id+2)
	e3:SetCondition(s.tfcon)
	e3:SetTarget(s.tftg)
	e3:SetOperation(s.tfop)
	c:RegisterEffect(e3)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
function s.rmfilter(c)
	return (c:IsCode(76200681) or aux.IsCodeListed(c,76200681))
		and not c:IsType(TYPE_TRAP) and c:IsAbleToRemove()
end
function s.thfilter(c)
	return (c:IsCode(76200681) or aux.IsCodeListed(c,76200681)) and c:IsAbleToHand()
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and g:GetFirst():IsLocation(0x20) then
		if c:IsRelateToChain(0) and c:IsAbleToRemove()
			and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			if Duel.Remove(c,0x5,0x40)>0 and c:IsLocation(0x20) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
				Duel.HintSelection(sg)
				Duel.SendtoHand(sg,nil,0x40)
			end
		end
	end
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	re:IsActiveType(TYPE_MONSTER)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(p,Card.IsAbleToDeck,p,LOCATION_HAND,0,1,2,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		local ct=aux.PlaceCardsOnDeckBottom(p,g)
		if ct==0 then return end
		Duel.BreakEffect()
		Duel.Draw(p,ct,REASON_EFFECT)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
function s.pfilter(c,tp)
	return c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_TRAP)
		and not c:IsCode(id) and aux.IsCodeListed(c,76200681)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.pfilter,tp,0x31,0,1,nil,tp) end
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.pfilter),tp,0x31,0,1,1,nil,tp):GetFirst()
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
