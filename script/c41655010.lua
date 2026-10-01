-- 烬雪的丰饶·稔华
local s,id,o=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)
	s.jinxue_effect=e1
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
	local e9=e1:Clone()
	e9:SetCondition(s.cannotcon)
	e9:SetOperation(s.operation3)
	c:RegisterEffect(e9)
	s.jinxue_effect=e9
end
function s.thfilter(c)
	return c:IsSetCard(0xe93) and c:IsAbleToHand()
end
function s.thfilter2(c)
	return c:IsCode(41655000) and c:IsAbleToHand()
end
function s.thfilter3(c)
	return c:IsSetCard(0xe93) and c:IsAbleToHand()
		and (not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup())
end
function s.tdfilter(c)
	return c:IsSetCard(0xe93) and c:IsAbleToDeck()
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
			and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		if Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g2=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g2)
		end
	end
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,3,nil)
			and Duel.IsExistingMatchingCard(s.thfilter3,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,2,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_HAND+LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA)
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,3,3,nil)
	if g:GetCount()~=3 then return end
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	if not Duel.IsExistingMatchingCard(s.thfilter3,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,2,nil) then return end
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g2=Duel.SelectMatchingCard(tp,s.thfilter3,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,2,2,nil)
	Duel.SendtoHand(g2,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g2)
end
function s.cannotcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(e:GetHandler())<0
end
function s.operation3(e,tp,eg,ep,ev,re,r,rp)
	s.operation1(e,tp,eg,ep,ev,re,r,rp)
	s.operation2(e,tp,eg,ep,ev,re,r,rp)
end