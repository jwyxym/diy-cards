--炽神界的领主
local cm,m,o=GetID()
function cm.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FAIRY),4,2,nil,nil,5)
	c:EnableReviveLimit()
	--dam
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1)
	e1:SetCondition(cm.con)
	e1:SetTarget(cm.tg)
	e1:SetOperation(cm.op)
	c:RegisterEffect(e1)
	--set
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,m+3)
	e1:SetCondition(cm.con1)
	e1:SetCost(cm.cost1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(cm.con2)
	c:RegisterEffect(e2)
	--get effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetCondition(cm.mcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		c:RegisterEffect(e4)
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local a=e:GetHandler():GetOverlayCount()*400
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,a)
	if not Duel.IsExistingMatchingCard(nil,tp,LOCATION_FZONE,0,1,nil) then
		e:SetCategory(CATEGORY_GRAVE_ACTION)
	end
end
function cm.filter(c)
	return not c:IsForbidden() and c:IsCode(76200112)
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local a=e:GetHandler():GetOverlayCount()*400
	if Duel.Damage(1-tp,a,REASON_EFFECT)>0 and not Duel.IsExistingMatchingCard(nil,tp,LOCATION_FZONE,0,1,nil) and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(cm.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cm.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		Duel.MoveToField(sg:GetFirst(),tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
function cm.con1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_TRAP)
end
function cm.con2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_TRAP)
end
function cm.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) and Duel.GetMatchingGroupCount(cm.filter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)>0 end
	local sa=Duel.GetMatchingGroupCount(cm.filter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	local la=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local a=e:GetHandler():GetOverlayCount()
	if sa>la then sa=la end
	if sa>a then sa=a end
	local b=e:GetHandler():RemoveOverlayCard(tp,1,sa,REASON_COST)
	e:SetLabel(b)
end
function cm.filter1(c)
	return c:IsSetCard(0x721) and c:IsType(TYPE_TRAP) and c:IsSSetable() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end
function cm.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroupCount(cm.filter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)>0 end
end
function cm.op1(e,tp,eg,ep,ev,re,r,rp)
	local b=e:GetLabel()
	local sa=Duel.GetMatchingGroupCount(cm.filter1,tp,LOCATION_DECK,0,nil)
	local la=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if b>sa or b>la then return end
	local g=Duel.SelectMatchingCard(tp,cm.filter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,b,b,nil)
	if g then Duel.SSet(tp,g) end
end
function cm.effcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ and e:GetHandler():GetReasonCard():GetOriginalRace()&RACE_FAIRY~=0
end
function cm.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e3,true)
	end
end
function cm.mcon(e)
	return e:GetHandler():GetOriginalRace()==RACE_FAIRY
end