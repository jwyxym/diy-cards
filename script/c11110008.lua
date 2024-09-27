--降神的杜丝娜瑞尔妖
local m=11110008
local cm=_G["c"..m]
function c11110008.initial_effect(c)
aux.AddSynchroMixProcedure(c,cm.matfilter1,nil,nil,aux.NonTuner(cm.filter),1,99)
	c:EnableReviveLimit()
local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,m)
	e3:SetTarget(cm.atktg)
	e3:SetOperation(cm.atkop)
	c:RegisterEffect(e3)
local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,m+1000)
	e1:SetCondition(cm.condition)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.spstg)
	e1:SetOperation(cm.spsop)
	c:RegisterEffect(e1)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function cm.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter2,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.IsExistingMatchingCard(cm.filter2,tp,LOCATION_GRAVE,0,1,nil) end
local aa=Duel.SelectMatchingCard(tp,cm.filter2,tp,LOCATION_GRAVE,0,1,1,nil)
Duel.Remove(aa,POS_FACEUP,REASON_COST)
end
function cm.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	
	local gc=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.Destroy(gc,REASON_EFFECT)
   

end
function cm.filter2(c) 
	return c:IsSetCard(0xa61) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function cm.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,3,nil) and Duel.IsPlayerCanDraw(1) end
end
function cm.atkop(e,tp,eg,ep,ev,re,r,rp)
local aa=Duel.SelectMatchingCard(tp,cm.filter,tp,LOCATION_GRAVE,0,3,3,nil)
if Duel.SendtoDeck(aa,tp,2,REASON_EFFECT)>0 then
Duel.Draw(tp,1,REASON_EFFECT)
end
end
function cm.matfilter1(c,syncard)
	return c:IsTuner(syncard) or (c:IsRace(RACE_REPTILE) and c:IsAttribute(ATTRIBUTE_DARK))
end
function cm.filter(c) 
	return c:IsRace(RACE_REPTILE)
end 