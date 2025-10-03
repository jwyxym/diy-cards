--N-CH.039 《希望姬战纪-爱尔比斯·奥罗拉》
function c10112039.initial_effect(c)
	aux.AddMaterialCodeList(c,10100039)
	--synchro summon
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xd11),aux.FilterBoolFunction(Card.IsCode,10100039),1,1)
	c:EnableReviveLimit()
	--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c10112039.atkval)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,10112039)
	e2:SetCondition(c10112039.discon)
	e2:SetTarget(c10112039.distg)
	e2:SetOperation(c10112039.disop)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOEXTRA+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,10112039+2)
	e3:SetCondition(c10112039.tecon)
	e3:SetTarget(c10112039.tetg)
	e3:SetOperation(c10112039.teop)
	c:RegisterEffect(e3)
end
function c10112039.atkfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x314) and c:IsType(0x1) or c:IsAllTypes(TYPE_TRAP+TYPE_CONTINUOUS))
end
function c10112039.atkval(e,c)
	return Duel.GetMatchingGroupCount(c10112039.atkfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)
end
function c10112039.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
function c10112039.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function c10112039.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
		if tc:IsType(0x1) and tc:GetAttack()>0 then
			if c:IsRelateToEffect(e) and c:IsFaceup() then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(tc:GetAttack())
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
				c:RegisterEffect(e1)
			end
		end
	end
end
function c10112039.tecon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
function c10112039.tefilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
function c10112039.tetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c10112039.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c10112039.tefilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c10112039.tefilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
function c10112039.tosfilter(c,e,tp)
	if not c:IsSetCard(0xd11) or not c:IsType(0x1) then return false end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function c10112039.teop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		if Duel.SendtoDeck(tc,nil,2,0x40)>0 and tc:IsLocation(LOCATION_EXTRA) then
			if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c10112039.tosfilter),tp,0x11,0,1,nil,e,tp)
				and Duel.SelectYesNo(tp,aux.Stringid(10112039,0)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
				local gg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c10112039.tosfilter),tp,0x11,0,1,1,nil,e,tp)
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				local hc=gg:GetFirst()
				if hc then
					if hc:IsAbleToHand() and (not hc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
						Duel.SendtoHand(hc,nil,REASON_EFFECT)
						Duel.ConfirmCards(1-tp,hc)
					else
						Duel.SpecialSummon(hc,0,tp,tp,false,false,POS_FACEUP)
					end
				end
			end
		end
	end
end