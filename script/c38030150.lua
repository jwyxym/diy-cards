--超混合！
function c38030150.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c38030150.cost)
	e1:SetTarget(c38030150.target)
	e1:SetOperation(c38030150.activate)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,38030150)
	e2:SetCondition(c38030150.thcon)
	e2:SetTarget(c38030150.thtg)
	e2:SetOperation(c38030150.thop)
	c:RegisterEffect(e2)
	--counter
	Duel.AddCustomActivityCounter(38030150,ACTIVITY_SPSUMMON,c38030150.counterfilter)
end
function c38030150.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION)
end
function c38030150.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) and Duel.GetCustomActivityCount(38030150,tp,ACTIVITY_SPSUMMON)==0 end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c38030150.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c38030150.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION)
end
function c38030150.chkfilter(c,e,tp)
	return c:IsLevel(11,12) and c:IsType(TYPE_FUSION) and c:IsFacedown() and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function c38030150.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
		local cg=Duel.GetMatchingGroup(c38030150.chkfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
		return cg:GetClassCount(Card.GetCode)>=3 and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) and g:CheckSubGroup(aux.gfcheck,2,2,Card.IsControler,0,1)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c38030150.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsControler,0,1)
	if Duel.SendtoGrave(sg,REASON_EFFECT)==0 then return end
	local og=Duel.GetOperatedGroup()
	if og:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==0 or not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	local g=Duel.GetMatchingGroup(c38030150.chkfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if g:GetClassCount(Card.GetCode)<3 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local cg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	if #cg==0 then return end
	Duel.ConfirmCards(1-tp,cg)
	local sc=cg:RandomSelect(1-tp,1):GetFirst()
	sc:SetMaterial(nil)
	if Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)~=0 then
		sc:CompleteProcedure()
		local fid=e:GetHandler():GetFieldID()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		if Duel.GetTurnPlayer()==tp then
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e1:SetLabel(0)
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		end
		e1:SetLabelObject(sc)
		e1:SetValue(fid)
		e1:SetCondition(c38030150.tdcon)
		e1:SetOperation(c38030150.tdop)
		Duel.RegisterEffect(e1,tp)
		sc:RegisterFlagEffect(38030150,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	end
end
function c38030150.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetTurnPlayer()==tp
end
function c38030150.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(38030150)==e:GetValue() then
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function c38030150.confilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and (c:GetPreviousTypeOnField()&TYPE_FUSION)>0 and c:IsPreviousControler(tp)
end
function c38030150.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c38030150.confilter,1,nil,tp)
end
function c38030150.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() or e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function c38030150.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetHandler():IsRelateToChain() then
		if c:IsAbleToHand() and (not c:IsSSetable() or Duel.SelectOption(tp,1190,1153)==0) then
			Duel.SendtoHand(c,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,c)
		else
			Duel.SSet(tp,c)
		end
	end
end
