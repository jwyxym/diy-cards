--扫荡的四方主
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.counterfilter)
end
function s.counterfilter(re,tp,cid)
	return not re:GetHandler():IsCode(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
function s.spfilter(c)
	return c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	if Duel.Destroy(sg,REASON_EFFECT)~=0 then
		if Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil)
			if g:GetCount()>0 then
				Duel.HintSelection(g)
				Duel.SendtoHand(g,tp,REASON_EFFECT)
			end
		end
		if Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,2,nil)
			if g:GetCount()>0 then
				Duel.HintSelection(g)
				Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
		if Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>2 then
			local ct=5-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
			if ct>0 then
				Duel.Draw(tp,ct,REASON_EFFECT)
			end
		end
		if Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>3 then
			local turnp=Duel.GetTurnPlayer()
				Duel.SkipPhase(turnp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
				Duel.SkipPhase(turnp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
				Duel.SkipPhase(turnp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_BP)
				e1:SetTargetRange(1,0)
				e1:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e1,turnp)
		end
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)==0
end