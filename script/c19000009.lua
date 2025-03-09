--伟大化身
function c19000009.initial_effect(c)
	--Normal monster
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_TYPE)
	e0:SetRange(LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE)
	e0:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e0)
	local e1=e0:Clone()
	e1:SetCode(EFFECT_REMOVE_TYPE)
	e1:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19000009,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,19000009)
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetCost(c19000009.sumcost)
	e2:SetTarget(c19000009.sumtg)
	e2:SetOperation(c19000009.sumop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19000009,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e3:SetCountLimit(1,19000009+100)
	e3:SetLabelObject(e0)
	e3:SetCondition(c19000009.spcon)
	e3:SetTarget(c19000009.sptg)
	e3:SetOperation(c19000009.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	--disable summon
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e6:SetRange(LOCATION_MZONE)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(1,0)
	e6:SetTarget(c19000009.sumlimit)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e7)
end
function c19000009.copyfilter(c)
	return (c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_EARTH)) and not c:IsPublic()
end
function c19000009.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c19000009.copyfilter,tp,LOCATION_EXTRA,0,1,nil) and c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
	local g=Duel.SelectMatchingCard(tp,c19000009.copyfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabelObject(g:GetFirst())
	Duel.ShuffleExtra(tp)
end
function c19000009.sumfilter(c)
	return (c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_EARTH)) and c:IsSummonable(true,nil)
end
function c19000009.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19000009.sumfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function c19000009.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,c19000009.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Summon(tp,g:GetFirst(),true,nil)
	end
end
function c19000009.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsControler(tp) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_EARTH)
		and (se==nil or c:GetReasonEffect()~=se)
end
function c19000009.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c19000009.cfilter,1,nil,tp,se)
end
function c19000009.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c19000009.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function c19000009.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:GetAttribute()~=ATTRIBUTE_EARTH 
end