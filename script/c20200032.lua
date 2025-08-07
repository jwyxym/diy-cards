--疯狂国度的等待
function c20200032.initial_effect(c)
	--indes
	aux.EnableChangeCode(c,20200003,LOCATION_DECK+LOCATION_GRAVE)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,20200032+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c20200032.cost)
	e1:SetCondition(c20200032.condition)
	e1:SetOperation(c20200032.activate)
	c:RegisterEffect(e1)
end
function c20200032.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function c20200032.costfilter(c)
	return c:IsCode(20200003) and c:IsAbleToGraveAsCost()
end
function c20200032.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20200032.costfilter,tp,LOCATION_ONFIELD+LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c20200032.costfilter,tp,LOCATION_ONFIELD+LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function c20200032.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateAttack() then
		Duel.BreakEffect()
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
