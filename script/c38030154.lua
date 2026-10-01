--灾杰的继承者
function c38030154.initial_effect(c)
	aux.AddCodeList(c,38030151)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,38030154+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c38030154.cost)
	e1:SetTarget(c38030154.target)
	e1:SetOperation(c38030154.activate)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,38030154)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c38030154.sptg)
	e2:SetOperation(c38030154.spop)
	c:RegisterEffect(e2)
end
function c38030154.ctfilter(c)
	return c:IsCode(38030151) and c:IsCanAddCounter(0x611,2) and c:IsFaceup()
end
function c38030154.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function c38030154.thfilter(c,chk)
	return chk==1 and c:IsSetCard(0x5616) or chk==2 and c:IsSetCard(0x6616) and c:IsType(TYPE_MONSTER)
end
function c38030154.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,c38030154.thfilter,1,2) and Duel.IsExistingMatchingCard(c38030154.ctfilter,tp,LOCATION_FZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function c38030154.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_DECK,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,c38030154.thfilter,1,2)
	if #tg==0 then return end
	Duel.SendtoHand(tg,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tg)
	if Duel.IsExistingMatchingCard(c38030154.ctfilter,tp,LOCATION_FZONE,0,1,nil) then
		Duel.BreakEffect()
		local tc=Duel.GetMatchingGroup(c38030154.ctfilter,tp,LOCATION_FZONE,0,nil):GetFirst()
		tc:AddCounter(0x611,2)
	end
end
function c38030154.spfilter(c,e,tp)
	return c:IsCode(38030153) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function c38030154.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c38030154.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end--Duel.IsPlayerAffectedByEffect(tp,59822133)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c38030154.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,c38030154.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if sc then
		sc:SetMaterial(nil)
		Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
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
		e1:SetCondition(c38030154.tdcon)
		e1:SetOperation(c38030154.tdop)
		Duel.RegisterEffect(e1,tp)
		sc:RegisterFlagEffect(38030154,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	end
end
function c38030154.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetTurnPlayer()==tp
end
function c38030154.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(38030154)==e:GetValue() then
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
