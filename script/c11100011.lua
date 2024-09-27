--铁机龙战甲·炎铠武装
local m=11100011
local cm=_G["c"..m]
function c11100011.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
   aux.AddLinkProcedure(c,cm.mfilter,2,2,cm.lcheck)
 local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,m)
	e3:SetTarget(cm.tg1)
	e3:SetOperation(cm.op1)
	c:RegisterEffect(e3)
 local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,m+1000)
	e1:SetCondition(cm.con1)
	e1:SetCost(cm.spcost)
	e1:SetOperation(cm.spop)
	c:RegisterEffect(e1)
local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(cm.regcon)
	e2:SetOperation(cm.regop)
	c:RegisterEffect(e2)
end
function cm.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(cm.splimit)
	Duel.RegisterEffect(e1,tp)
end
function cm.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(m) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=e:GetHandler():GetMaterial()
	local ml=mg:FilterSelect(tp,cm.filter4,1,2,nil)
		Duel.SpecialSummon(ml,0,tp,tp,false,false,POS_FACEUP)
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
	return not c:IsSetCard(0xa60)
end
function cm.filter4(c)
return c:IsLocation(LOCATION_GRAVE)
end
function cm.con1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function cm.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Card.IsReleasable(e:GetHandler(),REASON_COST) end
   
	
	Duel.Release(e:GetHandler(),REASON_COST)
end
function cm.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter2,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.IsExistingMatchingCard(cm.filter1,tp,LOCATION_GRAVE,0,1,nil) and   Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function cm.op1(e,tp,eg,ep,ev,re,r,rp)
local ta=Duel.SelectMatchingCard(tp,cm.filter1,tp,LOCATION_GRAVE,0,1,1,nil)
if Duel.Remove(ta,POS_FACEUP,REASON_EFFECT)>0 then
local tb=Duel.SelectMatchingCard(tp,cm.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
Duel.SpecialSummon(tb,0,tp,tp,false,false,POS_FACEUP)
end
end
function cm.filter1(c)
return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xa60) and not c:IsType(TYPE_LINK) end
function cm.filter2(c,e,tp)
return c:IsSetCard(0xa60) and c:IsType(TYPE_MONSTER) and c:IsRace(RACE_PSYCHO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
end
function cm.mfilter(c)
	return c:IsLinkRace(RACE_PSYCHO)
end
function cm.lcheck(g)
	return g:IsExists(cm.lcfilter,1,nil)
end
function cm.lcfilter(c)
	return c:IsLinkType(TYPE_LINK) and c:IsLinkSetCard(0xa60)
end