--三位一体·魔蛇妖神女·杜丝娜瑞尔
local m=11110009
local cm=_G["c"..m]
function c11110009.initial_effect(c)
	aux.AddSynchroMixProcedure(c,cm.matfilter1,nil,nil,aux.NonTuner(cm.filter),1,99)
	c:EnableReviveLimit()
local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,m+1000)
	e2:SetCondition(cm.discon)
	e2:SetTarget(cm.distg)
	e2:SetOperation(cm.disop)
	c:RegisterEffect(e2)
local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,m)
	e2:SetCondition(cm.drcon)
	e2:SetTarget(cm.drtg)
	e2:SetOperation(cm.drop)
	c:RegisterEffect(e2)
end
function cm.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function cm.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,1)
end
function cm.drop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
   if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
   local aa=Duel.GetMatchingGroupCount(nil,tp,LOCATION_MZONE,0,nil)
   local bb=Duel.SelectMatchingCard(tp,Card.IsRace,tp,LOCATION_HAND+LOCATION_GRAVE,0,aa,aa,nil,RACE_REPTILE)
Duel.Remove(bb,POS_FACEUP,REASON_EFFECT)
   
   end
end
function cm.discon(e,tp,eg,ep,ev,re,r,rp)
local aa=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_GRAVE,0,nil)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and aa:GetClassCount(Card.GetCode)>=5 and rp~=tp and Duel.IsExistingMatchingCard(cm.filter2,tp,LOCATION_GRAVE,0,1,nil)
end
function cm.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
end
function cm.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function cm.matfilter1(c,syncard)
	return c:IsRace(RACE_REPTILE)
end
function cm.filter2(c) 
	return c:IsSetCard(0xa61) and c:IsType(TYPE_MONSTER)
end
function cm.filter(c) 
	return c:IsRace(RACE_REPTILE)
end