--
function c19990060.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,19990060)
	e1:SetCost(c19990060.cost)
	e1:SetCondition(c19990060.condition)
	e1:SetTarget(c19990060.target)
	e1:SetOperation(c19990060.activate)
	c:RegisterEffect(e1)
end
function c19990060.handfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb29) and c:IsType(TYPE_FUSION)
end
function c19990060.handcon(e,c)
	return Duel.IsExistingMatchingCard(c19990060.handfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function c19990060.costfilter(c)
	return c:IsSetCard(0xb29) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function c19990060.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c19990060.costfilter,1,nil) end
	local g=Duel.SelectReleaseGroup(tp,c19990060.costfilter,1,1,nil)
	Duel.Release(g,REASON_COST)
end
function c19990060.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK)
end
function c19990060.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19990060.cfilter,1,nil,1-tp)
end
function c19990060.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,1-tp,LOCATION_HAND)
end
function c19990060.filter(c,e,tp)
	return c:IsRelateToEffect(e) and c19990060.cfilter(c,tp)
end
function c19990060.rmfilter(c,g)
	return c:IsAbleToRemove() and g:IsExists(Card.IsCode,1,nil,c:GetCode())
end
function c19990060.activate(e,tp,eg,ep,ev,re,r,rp)
	local dg=eg:Filter(c19990060.filter,nil,e,1-tp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		Duel.ConfirmCards(tp,g)
		local tg=g:Filter(c19990060.rmfilter,nil,dg)
		if tg:GetCount()>0 then
			Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
		end
		Duel.ShuffleHand(1-tp)
	end
end