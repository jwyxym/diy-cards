--太阳之力
local m=50000030
local cm=_G["c"..m]
function c50000030.initial_effect(c)
	aux.AddXyzProcedure(c,nil,12,2,cm.ovfilter,aux.Stringid(m,0),2,cm.xyzop)
	c:EnableReviveLimit()
   local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,m)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op3)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,2))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,m+1000)
	e2:SetCondition(cm.con1)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op4)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,m+1000)
	e3:SetCondition(cm.con2)
	e3:SetTarget(cm.tg2)
	e3:SetOperation(cm.op4)
	c:RegisterEffect(e3)
end
function cm.ovfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsDisabled()
end
function cm.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,m)==0 end
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function cm.checkop(e,tp,eg,ep,ev,re,r,rp)
	if cm.check(Duel.GetAttacker()) or cm.check(Duel.GetAttackTarget()) then
		Duel.RegisterFlagEffect(tp,50000030,RESET_PHASE+PHASE_END,0,1)
		Duel.RegisterFlagEffect(1-tp,50000030,RESET_PHASE+PHASE_END,0,1)
	end
end


function cm.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
function cm.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter2,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end
function cm.op3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tc=Duel.SelectMatchingCard(tp,cm.filter2,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.Destroy(tc,REASON_EFFECT)
end
function cm.filter3(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_EFFECT)
end
function cm.filter4(c)
	return (c:IsType(TYPE_RITUAL) or c:IsType(TYPE_FUSION) or c:IsType(TYPE_XYZ) or c:IsType(TYPE_SYNCHRO) or c:IsType(TYPE_LINK) or c:IsType(TYPE_PENDULUM)) and c:IsAbleToDeck()
end
function cm.con1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.filter3,1,nil,tp) 
end
function cm.con2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_EFFECT)
end
function cm.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter4,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
end
function cm.op4(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc=Duel.SelectMatchingCard(tp,cm.filter4,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
end






















