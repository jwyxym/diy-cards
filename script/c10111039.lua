--N-CH.039 《希望姬战纪-爱尔比斯·安布拉》
function c10111039.initial_effect(c)
	aux.AddMaterialCodeList(c,10100039)
	--synchro summon
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xd11),aux.FilterBoolFunction(Card.IsCode,10100039),1,1)
	c:EnableReviveLimit()
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,10111039)
	e1:SetTarget(c10111039.destg)
	e1:SetOperation(c10111039.desop)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,10111039+1)
	e2:SetTarget(c10111039.destg2)
	e2:SetOperation(c10111039.desop2)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOEXTRA+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,10111039+2)
	e3:SetCondition(c10111039.tecon)
	e3:SetTarget(c10111039.tetg)
	e3:SetOperation(c10111039.teop)
	c:RegisterEffect(e3)
end
function c10111039.cfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x314) and c:IsType(0x1) or c:IsAllTypes(TYPE_TRAP+TYPE_CONTINUOUS))
end
function c10111039.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c10111039.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c10111039.desop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(c10111039.cfilter,tp,LOCATION_ONFIELD,0,nil)
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function c10111039.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c10111039.desop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if Duel.Destroy(tc,REASON_EFFECT)>0 and tc:IsType(0x1) then
			Duel.Damage(1-tp,tc:GetAttack(),REASON_EFFECT)
		end
	end
end
function c10111039.tecon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
function c10111039.tefilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
function c10111039.tetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c10111039.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c10111039.tefilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c10111039.tefilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
function c10111039.tosfilter(c,e,tp)
	if not c:IsSetCard(0xd11) or not c:IsType(0x1) then return false end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function c10111039.teop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		if Duel.SendtoDeck(tc,nil,2,0x40)>0 and tc:IsLocation(LOCATION_EXTRA) then
			if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c10111039.tosfilter),tp,0x11,0,1,nil,e,tp)
				and Duel.SelectYesNo(tp,aux.Stringid(10111039,0)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
				local gg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c10111039.tosfilter),tp,0x11,0,1,1,nil,e,tp)
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