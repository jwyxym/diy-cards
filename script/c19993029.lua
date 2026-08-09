--
function c19993029.initial_effect(c)
	--special summon self
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,19993029)
	e0:SetCost(c19993029.spcost1)
	e0:SetTarget(c19993029.sptg1)
	e0:SetOperation(c19993029.spop1)
	c:RegisterEffect(e0)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,19993029+100)
	e1:SetCondition(c19993029.thcon)
	e1:SetTarget(c19993029.thtg)
	e1:SetOperation(c19993029.thop)
	c:RegisterEffect(e1)
	--xyzlv1
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_XYZ_LEVEL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c19993029.xyzlv1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetValue(c19993029.xyzlv2)
	c:RegisterEffect(e3)
end
function c19993029.cfilter1(c)
	return c:IsSetCard(0xb35) and c:IsType(TYPE_COUNTER) and c:IsAbleToGraveAsCost()
end
function c19993029.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19993029.cfilter1,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c19993029.cfilter1,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function c19993029.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c19993029.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c19993029.thcon(e,tp,eg,ep,ev,re,r,rp)
	return (e:GetHandler():IsLocation(LOCATION_GRAVE) or e:GetHandler():IsLocation(LOCATION_REMOVED)) and r==REASON_SYNCHRO
end
function c19993029.thfilter(c,e,tp)
	return c:IsSetCard(0xb35) and (c:IsType(TYPE_TRAP) or (c:IsType(TYPE_MONSTER) and c:IsLevel(4))) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function c19993029.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c19993029.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c19993029.thop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c19993029.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if g:GetCount()>0 and tc then
		tc:AddMonsterAttribute(TYPE_MONSTER+TYPE_TUNER)
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
function c19993029.xyzlv1(e,c,rc)
	return 0x60000+e:GetHandler():GetLevel()
end
function c19993029.xyzlv2(e,c,rc)
	return 0x80000+e:GetHandler():GetLevel()
end