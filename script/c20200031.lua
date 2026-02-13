--“所以，仙境在哪里？”
function c20200031.initial_effect(c)
	c:SetUniqueOnField(1,0,20200031)
	--indes
	aux.EnableChangeCode(c,20200003,LOCATION_SZONE+LOCATION_GRAVE)
	--Activate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e2)
	--set
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_TO_DECK)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e0:SetCountLimit(1,20200031)
	e0:SetTarget(c20200031.settg)
	e0:SetOperation(c20200031.setop)
	c:RegisterEffect(e0)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE+LOCATION_MZONE)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetCountLimit(1)
	e1:SetCost(c20200031.thcost)
	e1:SetTarget(c20200031.thtg)
	e1:SetOperation(c20200031.thop)
	c:RegisterEffect(e1)
end
function c20200031.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and not c:IsForbidden() and c:CheckUniqueOnField(tp) end
end
function c20200031.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
function c20200031.costfilter(c)
	return c:IsCode(20200003) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToRemoveAsCost()
end
function c20200031.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c20200031.costfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c20200031.costfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,1,c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c20200031.thfilter(c)
	return c:IsCode(20200003) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function c20200031.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20200031.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function c20200031.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,c20200031.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if tc then
		Duel.SSet(tp,tc)
	end
end