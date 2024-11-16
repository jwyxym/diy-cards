--Data All Access
function c88188208.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,88188208+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c88188208.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88188208,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c88188208.tg)
	e2:SetOperation(c88188208.op)
	c:RegisterEffect(e2)
end
c88188208.SetCard_Numerical_Crack=true 
function c88188208.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_MESSAGE,1-tp,aux.Stringid(88188200,0))
	Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(88188200,0))
	Duel.RegisterFlagEffect(e:GetHandlerPlayer(),88188200,RESET_EVENT+RESETS_STANDARD,0,1)
end
function c88188208.mfilter(c)
	return c:IsSetCard(0xa590) and c:IsAbleToHand()
end
function c88188208.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c88188208.mfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_MESSAGE,1-tp,aux.Stringid(88188200,0))
	Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(88188200,0))
	Duel.RegisterFlagEffect(e:GetHandlerPlayer(),88188200,RESET_EVENT+RESETS_STANDARD,0,1)
end
function c88188208.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c88188208.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c88188208.atktg(e,c)
	return c:IsSetCard(0xa590)
end