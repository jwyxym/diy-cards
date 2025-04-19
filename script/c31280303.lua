--深池之焰 “苇草”
function c31280303.initial_effect(c)
	aux.AddCodeList(c,31280321)
	c:EnableReviveLimit()
	--检索公开
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,31280303)
	e1:SetCost(c31280303.cost)
	e1:SetTarget(c31280303.target)
	e1:SetOperation(c31280303.operation)
	c:RegisterEffect(e1)
    --破坏抽卡
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c31280303.condition1)
	e2:SetTarget(c31280303.target1)
	e2:SetOperation(c31280303.operation1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	c:RegisterEffect(e3)
end
function c31280303.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end
function c31280303.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xca3) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand() and not c:IsCode(31280303)
end
function c31280303.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280303.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c31280303.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c31280303.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
        if Duel.SelectYesNo(tp,aux.Stringid(31280303,0)) then
        	Duel.BreakEffect()
            Duel.ShuffleHand(tp)
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
			local sg=Duel.SelectMatchingCard(tp,c31280303.filter1,tp,LOCATION_HAND,0,1,1,nil)
			if sg:GetCount()>0 then
				Duel.ConfirmCards(1-tp,sg)
				local pc=sg:GetFirst()
				local e1=Effect.CreateEffect(pc)
				e1:SetDescription(66)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_PUBLIC)
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				pc:RegisterEffect(e1)
            end
		end
	end 
end
function c31280303.filter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xca3) and c:IsRace(RACE_DRAGON)
end
function c31280303.condition1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
function c31280303.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c31280303.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(700)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
           	Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end