--
function c20020002.initial_effect(c)
	--spsummon
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(20020002,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_SUMMON_SUCCESS)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e0:SetCountLimit(1,20020002)
	e0:SetTarget(c20020002.target)
	e0:SetOperation(c20020002.operation)
	c:RegisterEffect(e0)
	local e1=e0:Clone()
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1)
	c20020002.sps_effect=e1
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20020002,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,20020002+100)
	e1:SetCondition(c20020002.hspcon)
	e1:SetTarget(c20020002.hsptg)
	e1:SetOperation(c20020002.hspop)
	c:RegisterEffect(e1)
end
function c20020002.spfilter(c,e,tp)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0xb35)  and c:IsType(TYPE_TRAP) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function c20020002.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c20020002.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function c20020002.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c20020002.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if g:GetCount()>0 and tc then
		tc:AddMonsterAttribute(TYPE_MONSTER)
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
function c20020002.spsfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb35)
end
function c20020002.hspcon(e,c)
	return Duel.IsExistingMatchingCard(c20020002.spsfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c20020002.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c20020002.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end