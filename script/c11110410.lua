--人造的使者-蓓尔塔
local s,id=GetID()
function s.initial_effect(c)

	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.e1con)
	e1:SetValue(1000)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(1)
	e2:SetCondition(s.e2con)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCondition(s.e3con)
	e3:SetCost(s.e3cost)
	e3:SetTarget(s.e3tg)
	e3:SetOperation(s.e3op)
	c:RegisterEffect(e3)
end
function s.e1con(e)
	return Duel.GetCurrentPhase() >= PHASE_BATTLE_START 
		and Duel.GetCurrentPhase() <= PHASE_BATTLE
end
function s.e2con(e)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
function s.e3con(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep~=tp and (LOCATION_ONFIELD)&loc~=0
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
function s.e3cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.e3tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.e3op(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end