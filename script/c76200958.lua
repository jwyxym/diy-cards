--霜影的主仆
function c76200958.initial_effect(c)
	aux.AddCodeList(c,76200681)
	--destroy monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76200958,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,76200958)
	e1:SetCondition(c76200958.rmcon)
	e1:SetCost(c76200958.descost)
	e1:SetTarget(c76200958.destg)
	e1:SetOperation(c76200958.desop)
	c:RegisterEffect(e1)
	local e11=e1:Clone()
	e11:SetCondition(c76200958.descon)
	e11:SetCode(EVENT_CHAINING)
	c:RegisterEffect(e11)
	--to deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76200958,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,76200958+1)
	e2:SetCondition(aux.exccon)
	e2:SetTarget(c76200958.tdtg)
	e2:SetOperation(c76200958.tdop)
	c:RegisterEffect(e2)
end
function c76200958.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tn=Duel.GetTurnPlayer()
	return tn==tp
end
function c76200958.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function c76200958.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function c76200958.rmfilter(c)
	return (c:IsCode(76200681) or aux.IsCodeListed(c,76200681))
		and not c:IsRace(RACE_SPELLCASTER) and c:IsAbleToRemove()
end
function c76200958.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil)
		and Duel.IsExistingMatchingCard(c76200958.rmfilter,tp,0x41,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,0x41)
end
function c76200958.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c76200958.rmfilter,tp,0x41,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.BreakEffect()
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function c76200958.thfilter(c)
	return c:IsFaceup() and (c:IsCode(76200681) or aux.IsCodeListed(c,76200681))
		and not c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
function c76200958.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c76200958.thfilter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToDeck()
		and Duel.IsExistingTarget(c76200958.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,c76200958.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c76200958.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

