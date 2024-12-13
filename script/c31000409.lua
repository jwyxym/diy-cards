--清蓝之幻界
function c31000409.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,31000409)
	e1:SetOperation(c31000409.activate)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c31000409.target)
	e2:SetValue(c31000409.indct)
	c:RegisterEffect(e2)
	--atkdown
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,31000409+100)
	e3:SetCondition(c31000409.atkcon)
	e3:SetTarget(c31000409.atktg)
	e3:SetOperation(c31000409.atkop)
	c:RegisterEffect(e3)
	local e33=Effect.CreateEffect(c)
	e33:SetCategory(CATEGORY_ATKCHANGE)
	e33:SetType(EFFECT_TYPE_IGNITION)
	e33:SetRange(LOCATION_FZONE)
	e33:SetCountLimit(1,31000409+100)
	e33:SetCost(c31000409.atkcost)
	e33:SetTarget(c31000409.atktg)
	e33:SetOperation(c31000409.atkop)
	c:RegisterEffect(e33)
end
function c31000409.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x313) and c:IsAbleToHand()
end
function c31000409.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c31000409.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(31000409,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function c31000409.target(e,c)
	return c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_WIND+ATTRIBUTE_WATER)
end
function c31000409.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end
function c31000409.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
function c31000409.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,c,tp)
	Duel.SendtoGrave(g,REASON_COST)
end
function c31000409.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
function c31000409.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(nil,tp,0,LOCATION_MZONE,nil)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-ct*300)
		tc:RegisterEffect(e1)
	end
	local g2=Duel.GetMatchingGroup(c31000409.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(31000409,1)) then
		Duel.BreakEffect()
		local sc=g2:Select(tp,1,1,nil):GetFirst()
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(ct*300)
		sc:RegisterEffect(e2)
	end
end
function c31000409.atkfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_WIND+ATTRIBUTE_WATER) and c:IsFaceup()
end