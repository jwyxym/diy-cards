--不朽机骸 铁械医师
function c31280144.initial_effect(c)
	--种族视为机械族
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_RACE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND)
	e1:SetValue(RACE_MACHINE)
	c:RegisterEffect(e1)
	--墓地特召并回手
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31280144,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
    e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,31280144)
    e2:SetCondition(c31280144.condition)
	e2:SetTarget(c31280144.target)
	e2:SetOperation(c31280144.operation)
	c:RegisterEffect(e2)
	--墓地或除外特召    
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(31280144,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,31280144)
	e3:SetCondition(c31280144.condition1)
	e3:SetTarget(c31280144.target1)
	e3:SetOperation(c31280144.operation1)
	c:RegisterEffect(e3)    
end
function c31280144.cfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsControler(tp) and (c:IsRace(RACE_MACHINE) and c:GetOriginalRace()==RACE_ZOMBIE)
end
function c31280144.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31280144.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
function c31280144.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xca2) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c31280144.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c31280144.thfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c31280144.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,c31280144.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c31280144.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
function c31280144.ssfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsFaceup()
end
function c31280144.condition1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_FUSION 
    	and Duel.IsExistingMatchingCard(c31280144.ssfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c31280144.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0xca2) and c:IsType(TYPE_MONSTER) 
    	and not c:IsCode(31280144) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c31280144.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c31280144.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c31280144.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c31280144.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c31280144.operation1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end