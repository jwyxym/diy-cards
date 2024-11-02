--
function c19990019.initial_effect(c)
 --pendulum summon
	aux.EnablePendulumAttribute(c)
	--Special Summon1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19990019,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_REMOVED+LOCATION_HAND)
	e1:SetCountLimit(1,19990019)
	e1:SetCost(c19990019.tccost)
	e1:SetTarget(c19990019.spstg)
	e1:SetOperation(c19990019.spsop)
	c:RegisterEffect(e1)
	--Special Summon2
	local e2=Effect.CreateEffect(c)
	e2:SetCountLimit(1,19990019)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetTarget(c19990019.sptg)
	e2:SetOperation(c19990019.spop)
	c:RegisterEffect(e2)
end
function c19990019.cfilter(c,tp)
	return c:IsSetCard(0xb29)
end
function c19990019.tccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,c19990019.cfilter,1,REASON_COST,true,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroupEx(tp,c19990019.cfilter,1,1,REASON_COST,true,c,tp)
	Duel.Release(g,REASON_COST)
end
function c19990019.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetLocationCountFromEx(tp,tp,nil,c)>0) and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c19990019.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c19990019.filter(c,e,tp)
	return c:IsSetCard(0xb29) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and ((c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsFaceup()) or c:IsLocation(LOCATION_GRAVE)) 
end
function c19990019.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c19990019.filter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function c19990019.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c19990019.filter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
