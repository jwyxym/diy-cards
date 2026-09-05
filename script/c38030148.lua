--混合
function c38030148.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	--e1:SetHintTiming(0,TIMING_DRAW_PHASE+TIMING_END_PHASE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c38030148.cost)
	e1:SetTarget(c38030148.target)
	e1:SetOperation(c38030148.activate)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,38030148)
	e2:SetCondition(c38030148.thcon)
	e2:SetTarget(c38030148.thtg)
	e2:SetOperation(c38030148.thop)
	c:RegisterEffect(e2)
	--counter
	Duel.AddCustomActivityCounter(38030148,ACTIVITY_SPSUMMON,c38030148.counterfilter)
end
function c38030148.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION)
end
function c38030148.gcheck(g,tp)
	return Duel.GetLocationCountFromEx(tp,tp,g,TYPE_FUSION)>0
end
function c38030148.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_MZONE,0,nil):Filter(Card.IsType,nil,TYPE_MONSTER)
	if chk==0 then return g:CheckSubGroup(c38030148.gcheck,2,2,tp) and Duel.GetCustomActivityCount(38030148,tp,ACTIVITY_SPSUMMON)==0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:SelectSubGroup(tp,c38030148.gcheck,false,2,2,tp)
	Duel.SendtoGrave(sg,REASON_COST)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c38030148.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c38030148.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION)
end
function c38030148.chkfilter(c,e,tp,res)
	return c:IsLevelBelow(7) and c:IsType(TYPE_FUSION) and c:IsFacedown() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 or res)
end
function c38030148.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:IsCostChecked()
		local g=Duel.GetMatchingGroup(c38030148.chkfilter,tp,LOCATION_EXTRA,0,nil,e,tp,res)
		return g:GetClassCount(Card.GetCode)>=6
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c38030148.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c38030148.chkfilter,tp,LOCATION_EXTRA,0,nil,e,tp,false)
	if g:GetClassCount(Card.GetCode)<6 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local cg=g:SelectSubGroup(tp,aux.dncheck,false,6,6)
	if #cg==0 then return end
	Duel.ConfirmCards(1-tp,cg)
	local sc=cg:RandomSelect(1-tp,1):GetFirst()
	if Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)~=0 then
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
		e1:SetCondition(c38030148.tdcon)
		e1:SetOperation(c38030148.tdop)
		Duel.RegisterEffect(e1,tp)
		sc:RegisterFlagEffect(38030148,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	end
end
function c38030148.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetTurnPlayer()==tp
end
function c38030148.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(38030148)==e:GetValue() then
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function c38030148.confilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and (c:GetPreviousTypeOnField()&TYPE_FUSION)>0 and c:IsPreviousControler(tp)
end
function c38030148.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c38030148.confilter,1,nil,tp)
end
function c38030148.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() or e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function c38030148.thop(e,tp,eg,ep,ev,re,r,rp)
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
