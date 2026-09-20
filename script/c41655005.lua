-- 烬雪的睿智·芙尔德丽兹
local s,id,o=GetID()
function s.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--tohand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e9=e1:Clone()
	e9:SetCondition(s.cannotcon)
	e9:SetOperation(s.operation2)
	c:RegisterEffect(e9)
	s.jinxue_effect=e9
end
function s.filter(c)
	return c:IsSetCard(0xe93) and c:IsAbleToHand()
end
function s.thfilter(c)
	return c:IsCode(41655000) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetFlagEffect(tp,id)==0
	local b2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=2 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,2,nil) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetFlagEffect(tp,id+1)==0
	if chk==0 then return b1 or b2 end
	local op=aux.SelectFromOptions(tp,
	{b1,aux.Stringid(id,0)},
	{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	if op==1 then
		if e:IsCostChecked() then
			e:SetProperty(0)
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		if e:IsCostChecked() then
			Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
		end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
			if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
				Duel.SendtoHand(g2,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g2)
			end
		end
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,2,2,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
			if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
				Duel.SendtoHand(g2,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g2)
			end
		end
	end
end
function s.cannotcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(e:GetHandler())<0
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g2)
		end
	end
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,2,2,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
			if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
				Duel.SendtoHand(g2,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g2)
			end
		end
	end
end
