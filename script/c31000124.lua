--胜者之眼
function c31000124.initial_effect(c)
	--destroy drawn
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,31000124)
	e1:SetCondition(c31000124.con)
	e1:SetTarget(c31000124.target)
	e1:SetOperation(c31000124.activate)
	c:RegisterEffect(e1)
	--equip
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,31000124+1)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c31000124.eqtg)
	e2:SetOperation(c31000124.eqop)
	c:RegisterEffect(e2)
end
function c31000124.xfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x311) and c:IsType(TYPE_XYZ)
end
function c31000124.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DRAW
		and Duel.IsExistingMatchingCard(c31000124.xfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c31000124.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local gc=g:GetCount()
	if chk==0 then return gc>0 and g:FilterCount(Card.IsAbleToDeck,nil)==gc and Duel.IsPlayerCanDraw(1-tp) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,gc,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,gc)
end
function c31000124.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local gc=g:GetCount()
	if gc>0 and g:FilterCount(Card.IsAbleToDeck,nil)==gc then
		Duel.DisableShuffleCheck()
		local oc=Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
		if oc>0 then
			Duel.ShuffleDeck(1-tp)
			Duel.Draw(1-tp,oc,REASON_EFFECT)
		end
	end
end
function c31000124.tgfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(c31000124.eqfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,c)
end
function c31000124.eqfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
		and c:IsSetCard(0x311)
end
function c31000124.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c31000124.tgfilter(chkc,tp) end
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		return ft>0 and Duel.IsExistingTarget(c31000124.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,c31000124.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function c31000124.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ec=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c31000124.eqfilter),tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,tc,tp):GetFirst()
	if ec and Duel.Equip(tp,ec,tc)then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetLabelObject(tc)
		e1:SetValue(c31000124.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
	end
end
function c31000124.eqlimit(e,c)
	return c==e:GetLabelObject()
end