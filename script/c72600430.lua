--龙神之魂
local s,id,o=GetID()
function s.initial_effect(c)
	--boost
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetCondition(aux.dscon)
	e1:SetCost(s.adcost)
	e1:SetTarget(s.adtg)
	e1:SetOperation(s.adop)
	c:RegisterEffect(e1)
	--spsum self
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1+EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.adtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.adop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON+RACE_WYRM) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_SYNCHRO)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.spfilter(c,tp,chk)
	return c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeck()
		and (Duel.GetMZoneCount(tp,c)>0 or not chk)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,nil,tp,true)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local rg=nil
	if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED+LOCATION_HAND,0,1,nil,tp,true) then
		rg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED+LOCATION_HAND,0,1,1,nil,tp,true)
	else
		rg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED+LOCATION_HAND,0,1,1,nil,tp,false)
	end
	if rg and rg:GetCount()>0 then
		if rg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,rg)
		else
			Duel.HintSelection(rg)
		end
		if Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
			and rg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)>0
			and c:IsRelateToChain() and aux.NecroValleyFilter()(c)
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1,true)
		end
		Duel.SpecialSummonComplete()
	end
end
