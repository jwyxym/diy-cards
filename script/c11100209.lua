--极巧机神·星斗辰
function c11100209.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,c11100209.mfilter,nil,2,2)
	--battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--destroy replace
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e11:SetCode(EFFECT_DESTROY_REPLACE)
	e11:SetRange(LOCATION_MZONE)
	e11:SetTarget(c11100209.desreptg)
	e11:SetValue(c11100209.desrepval)
	e11:SetOperation(c11100209.desrepop)
	c:RegisterEffect(e11)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,11100209)
	e2:SetCondition(c11100209.descon)
	e2:SetCost(c11100209.descost)
	e2:SetTarget(c11100209.destg)
	e2:SetOperation(c11100209.desop)
	c:RegisterEffect(e2)
end
function c11100209.mfilter(c,xyzc)
	return c:IsRace(RACE_MACHINE)
		and (c:IsXyzLevel(xyzc,10) or (aux.AtkEqualsDef(c) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)))
end
function c11100209.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField()
		and aux.AtkEqualsDef(c) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function c11100209.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c11100209.repfilter,1,nil,tp)
		and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function c11100209.desrepval(e,c)
	return c11100209.repfilter(c,e:GetHandlerPlayer())
end
function c11100209.desrepop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	Duel.Hint(HINT_CARD,0,11100209)
end
function c11100209.cfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_NORMAL)
end
function c11100209.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c11100209.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
function c11100209.desfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAbleToRemoveAsCost()
end
function c11100209.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11100209.desfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c11100209.desfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c11100209.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c11100209.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end