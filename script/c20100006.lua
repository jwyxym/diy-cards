--PLU-Infection Epidemic Continent
function c20100006.initial_effect(c)
	c:SetUniqueOnField(1,0,20100006)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	--remove or speicial summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20100006,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,20100006)
	e2:SetTarget(c20100006.target)
	e2:SetOperation(c20100006.operation)
	c:RegisterEffect(e2)
	--disable summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c20100006.sumlimit)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e5)
	--setcard
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(LOCATION_REMOVED,LOCATION_REMOVED)
	e6:SetCode(EFFECT_ADD_SETCODE)
	e6:SetValue(0xb28)
	e6:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
	c:RegisterEffect(e6)
end
function c20100006.filter(c,e,tp,spchk)
	return c:IsSetCard(0xb28) and (c:IsAbleToRemove() or (spchk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function c20100006.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local spchk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c20100006.filter(c,e,tp,spchk) end
	if chk==0 then return Duel.IsExistingTarget(c20100006.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,spchk) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,c20100006.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp,spchk)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,PLAYER_ALL,LOCATION_GRAVE)
end
function c20100006.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and (not tc:IsAbleToRemove() or Duel.SelectYesNo(tp,aux.Stringid(20100006,1))) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end
function c20100006.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0xb28)
end