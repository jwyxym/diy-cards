--铁机龙战场·集结地
local m=11100001
local cm=_G["c"..m]
function c11100001.initial_effect(c)
	 local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,m+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(cm.condition)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e3:SetTarget(cm.target)
	e3:SetValue(cm.indvalue)
	c:RegisterEffect(e3)
end
function cm.indvalue(e,re)
	return re:GetHandlerPlayer()~=e:GetHandlerPlayer()
end
function cm.filter(c,tp)
	return c:IsSetCard(0xa60) 
end
function cm.filter2(c,tp,code)
	return c:IsSetCard(0xa60) and not c:IsCode(code)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) and Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
if Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
local g1=Duel.SelectMatchingCard(tp,cm.filter,tp,LOCATION_HAND,0,1,1,nil,tp)
local code=g1:GetFirst():GetCode()
 Duel.ConfirmCards(1-tp,g1) 
 Duel.ShuffleHand(tp) 

local tc=Duel.SelectMatchingCard(tp,cm.filter2,tp,LOCATION_DECK,0,1,1,nil,tp,code)
if Duel.SelectYesNo(tp,aux.Stringid(m,1)) then
Duel.SendtoHand(tc,nil,REASON_EFFECT)
else
Duel.SendtoGrave(tc,REASON_EFFECT)
end
end
end
function cm.filter3(c,tp,tc)
local seq=tc:GetSequence()
	local a
	local b
	if seq>0 then a=seq-1 end
	if seq<4 then b=seq+1 end
	return c:IsRace(RACE_PSYCHO) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsControler(tp) and (c:GetSequence()==a or c:GetSequence()==b)
end
function cm.target(e,c,tp,eg,ep,ev,re,r,rp)
   return c:IsSetCard(0xa60) and c:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(cm.filter3,tp,LOCATION_MZONE,0,1,nil,tp,c)
end












