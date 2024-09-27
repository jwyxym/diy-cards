--铁机龙战·结晶核心
local m=11100006
local cm=_G["c"..m]
function c11100006.initial_effect(c)
	 local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,m)
	e3:SetTarget(cm.sptg)
	e3:SetOperation(cm.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,m)
	e2:SetCondition(cm.con2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end
function cm.op2(e,tp,eg,ep,ev,re,r,rp)
local seq=e:GetHandler():GetSequence()
	local a
	local b
	if seq>0 then a=seq-1 end
	if seq<4 then b=seq+1 end
if eg:IsExists(cm.filter4,1,nil,tp,a,b) and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
Duel.SendtoHand(e:GetHandler(),tp,REASON_EFFECT)
else
Duel.SendtoHand(eg:GetFirst(),tp,REASON_EFFECT)
end
local ta=Duel.SelectMatchingCard(tp,cm.filter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,eg:GetFirst():GetLevel())
Duel.SpecialSummon(ta,0,tp,tp,false,false,POS_FACEUP)
local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetTargetRange(1,0)
	e2:SetTarget(cm.splimit2)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function cm.filter2(c,e,tp,level)
	return c:IsRace(RACE_PSYCHO) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevel(level)
end
function cm.con2(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetHandler():GetSequence()
	local a
	local b
	if seq>0 then a=seq-1 end
	if seq<4 then b=seq+1 end
	return eg:IsExists(cm.filter3,1,nil,tp,a,b) and not eg:IsContains(e:GetHandler())
end
function cm.filter4(c,tp,a,b)
	return c:IsSetCard(0xa60) and c:IsType(TYPE_MONSTER) and c:IsControler(tp) and (c:GetSequence()==a or c:GetSequence()==b)
end
function cm.filter3(c,tp,a,b)
	return c:IsRace(RACE_PSYCHO) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsControler(tp) and (c:GetSequence()==a or c:GetSequence()==b)
end
function cm.spfilter(c,e,tp)
	return c:IsRace(RACE_PSYCHO) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cm.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 and Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
 local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetTargetRange(1,0)
	e2:SetTarget(cm.splimit2)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end

function cm.splimit2(e,c,sump,sumtype,sumpos,targetp)
	return c:IsSummonLocation(LOCATION_EXTRA) and not (c:IsSetCard(0xa60) and c:IsType(TYPE_LINK))
end




