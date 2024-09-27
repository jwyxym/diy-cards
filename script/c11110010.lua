--杜丝娜瑞尔之城
local m=11110010
local cm=_G["c"..m]
function c11110010.initial_effect(c)
local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_ACTIVATE) 
	e1:SetCode(EVENT_FREE_CHAIN) 
	c:RegisterEffect(e1) 
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
	e3:SetCondition(cm.con)
	e3:SetValue(cm.atkval)
	c:RegisterEffect(e3)
local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
	e2:SetCondition(cm.con)
	e2:SetValue(cm.atkval)
	c:RegisterEffect(e2)
local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCountLimit(1,m)
	e4:SetCondition(cm.rmcon)
	e4:SetTarget(cm.rmtg)
	e4:SetOperation(cm.rmop)
	c:RegisterEffect(e4)
end
function cm.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(cm.cfilter,1,nil,tp)
end
function cm.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsControler(tp) and c:IsSetCard(0xa61)
end
function cm.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsRace(RACE_REPTILE) and c:IsLevelBelow(4)
end
function cm.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED,0,1,nil,e,tp) end
end
function cm.rmop(e,tp,eg,ep,ev,re,r,rp)
local a=Duel.SelectMatchingCard(tp,cm.filter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED,0,1,1,nil,e,tp)
Duel.SpecialSummon(a,0,tp,tp,false,false,POS_FACEUP)
end
function cm.con(e,tp)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(cm.atkfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function cm.atkfilter(c)
	return c:IsRace(RACE_REPTILE)
end
function cm.atkval(e,c)
	return Duel.GetMatchingGroupCount(cm.atkfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)*100
end





