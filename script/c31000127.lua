--初代·布里托玛特
function c31000127.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,31000127)
	e1:SetCondition(c31000127.spcon)
	e1:SetTarget(c31000127.sptg)
	e1:SetOperation(c31000127.spop)
	c:RegisterEffect(e1)
	--lvchange
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31000127,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,31000127+1)
	e2:SetTarget(c31000127.lvtg)
	e2:SetOperation(c31000127.lvop)
	c:RegisterEffect(e2)
end
function c31000127.cfilter(c)
	return c:IsFacedown() or not c:IsAttribute(ATTRIBUTE_WIND)
end
function c31000127.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(c31000127.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c31000127.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c31000127.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c31000127.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(c31000127.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
		if g1:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(31000127,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g2=g1:Select(tp,1,1,nil)
			Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c31000127.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function c31000127.splimit(e,c)
	return not (c:IsSetCard(0x311) or c:IsType(TYPE_XYZ)) and c:IsLocation(LOCATION_EXTRA)
end
function c31000127.lvfilter(c,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsLevelAbove(1)
		and Duel.IsExistingMatchingCard(c31000127.lvfilter2,tp,LOCATION_MZONE,0,1,c,c:GetLevel())
end
function c31000127.lvfilter2(c,lv)
	return c:IsFaceup() and c:IsLevelAbove(1) and not c:IsLevel(lv)
end
function c31000127.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c31000127.lvfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(c31000127.lvfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c31000127.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function c31000127.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		local sc=Duel.SelectMatchingCard(tp,c31000127.lvfilter2,tp,LOCATION_MZONE,0,1,1,tc,tc:GetLevel()):GetFirst()
		if sc then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(tc:GetLevel())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
		end
	end
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c31000127.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end