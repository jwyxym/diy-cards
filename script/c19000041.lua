--天下龙侠，一往无前！
function c19000041.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,19000041+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c19000041.target)
	e1:SetOperation(c19000041.activate)
	c:RegisterEffect(e1)
end
function c19000041.tgfilter(c,tp)
	return c:IsAbleToGrave() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
function c19000041.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19000041.tgfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
function c19000041.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c19000041.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) and Duel.SelectYesNo(tp,aux.Stringid(19000041,1)) then
		local att=tc:GetOriginalAttribute()
		if att==ATTRIBUTE_WIND then 
		Duel.Draw(tp,1,REASON_EFFECT)
		elseif att==ATTRIBUTE_WATER then 
		Duel.Recover(tp,1000,REASON_EFFECT)
		elseif att==ATTRIBUTE_EARTH then 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local eg=Duel.SelectMatchingCard(tp,c19000041.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if eg:GetCount()>0 then
		  Duel.SendtoHand(eg,nil,REASON_EFFECT)
		  Duel.ConfirmCards(1-tp,eg)
		end
		elseif att==ATTRIBUTE_FIRE then 
		Duel.Damage(1-tp,1000,REASON_EFFECT)
		elseif att==ATTRIBUTE_LIGHT then 
		if Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)==0 then return end
		local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0):RandomSelect(tp,1)
		local tc=g:GetFirst()
		Duel.ConfirmCards(tp,tc)
		Duel.ShuffleHand(1-tp)
		elseif att==ATTRIBUTE_DARK then 
		if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsFacedown() end
		if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
		Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,1,nil)
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and tc:IsFacedown() then
		Duel.ConfirmCards(tp,tc)
		end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsRace),RACE_DRAGON))
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
end
function c19000041.thfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end

