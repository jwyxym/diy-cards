--潜袭之影
function c76200967.initial_effect(c)
	aux.AddCodeList(c,76200681)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMING_MAIN_END)
	c:RegisterEffect(e0)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76200967,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,76200967)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(c76200967.rmcon)
	e1:SetTarget(c76200967.rmtg)
	e1:SetOperation(c76200967.rmop)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76200967,2))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,76200967+1)
	e2:SetCondition(c76200967.tdcon)
	e2:SetTarget(c76200967.tdtg)
	e2:SetOperation(c76200967.tdop)
	c:RegisterEffect(e2)
	--to hand
	local e33=Effect.CreateEffect(c)
	e33:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e33:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e33:SetCode(EVENT_REMOVE)
	e33:SetOperation(c76200967.regop)
	c:RegisterEffect(e33)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_GRAVE_ACTION)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,76200967+2)
	e3:SetCondition(c76200967.tfcon)
	e3:SetTarget(c76200967.tftg)
	e3:SetOperation(c76200967.tfop)
	c:RegisterEffect(e3)
end
function c76200967.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(76200967,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function c76200967.tfcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(76200967)>0
end
function c76200967.pfilter(c,tp)
	return c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_TRAP)
		and not c:IsCode(76200967) and aux.IsCodeListed(c,76200681)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function c76200967.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(c76200967.pfilter,tp,0x31,0,1,nil,tp) end
end
function c76200967.tfop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c76200967.pfilter),tp,0x31,0,1,1,nil,tp):GetFirst()
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
function c76200967.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function c76200967.tdfilter(c)
	return (c:IsCode(76200681) or aux.IsCodeListed(c,76200681)) and (c:IsAbleToDeck() or c:IsAbleToGrave())
end
function c76200967.tdfilter2(c)
	return c:IsAbleToDeck() or c:IsAbleToGrave()
end
function c76200967.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c76200967.tdfilter,tp,0x20,0,1,nil) end
end
function c76200967.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,c76200967.tdfilter,tp,0x20,0,1,1,nil)
	if g:GetCount()<=0 then return end
	Duel.HintSelection(g)
	local tc=g:GetFirst()
	local ck=0
	if tc:IsAbleToDeck() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,aux.Stringid(76200967,5),aux.Stringid(76200967,6))==0) then
		if Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)>0 and tc:IsLocation(0x1) then ck=1 end
	else
		if Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)>0 and tc:IsLocation(0x10) then ck=1 end
	end
	if ck>0 and Duel.IsExistingMatchingCard(c76200967.tdfilter2,tp,0x20,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(76200967,4)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		local sg=Duel.SelectMatchingCard(tp,c76200967.tdfilter2,tp,0x20,0,1,1,nil)
		if sg:GetCount()<=0 then return end
		Duel.HintSelection(sg)
		local sc=sg:GetFirst()
		if sc:IsAbleToDeck() and (not sc:IsAbleToGrave() or Duel.SelectOption(tp,aux.Stringid(76200967,5),aux.Stringid(76200967,6))==0) then
			Duel.SendtoDeck(sc,nil,2,REASON_EFFECT)
		else
			Duel.SendtoGrave(sc,REASON_EFFECT+REASON_RETURN)
		end
	end
end
function c76200967.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
function c76200967.rmfilter(c)
	return (c:IsCode(76200681) or aux.IsCodeListed(c,76200681))
		and not c:IsType(0x4) and c:IsAbleToRemove()
end
function c76200967.thfilter(c)
	return (c:IsCode(76200681) or aux.IsCodeListed(c,76200681)) and c:IsAbleToHand()
end
function c76200967.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c76200967.rmfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function c76200967.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c76200967.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and g:GetFirst():IsLocation(0x20) then
		if c:IsRelateToChain(0) and c:IsAbleToRemove()
			and Duel.IsExistingMatchingCard(c76200967.thfilter,tp,LOCATION_REMOVED,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(76200967,3)) then
			Duel.BreakEffect()
			if Duel.Remove(c,0x5,0x40)>0 and c:IsLocation(0x20) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local sg=Duel.SelectMatchingCard(tp,c76200967.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
				Duel.HintSelection(sg)
				Duel.SendtoHand(sg,nil,0x40)
			end
		end
	end
end