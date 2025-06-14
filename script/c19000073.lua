--像素点阵未来
function c19000073.initial_effect(c)
	aux.AddCodeList(c,19000072,19000069)
	--Activate 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetDescription(aux.Stringid(19000073,0))
	e1:SetCountLimit(1,19000073+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c19000073.target1)
	e1:SetOperation(c19000073.activate1)
	c:RegisterEffect(e1)
	--Activate 2
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetDescription(aux.Stringid(19000073,1))
	e2:SetCountLimit(1,19000073+EFFECT_COUNT_CODE_OATH)
	e2:SetCost(c19000073.cost2)
	e2:SetTarget(c19000073.target2)
	e2:SetOperation(c19000073.activate2)
	c:RegisterEffect(e2)
end
function c19000073.cfilter1(c)
	return c:IsCode(19000072) and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(c19000073.filter1,tp,LOCATION_DECK,0,1,nil,c)
end
function c19000073.filter1(c,mc)
	return aux.IsCodeListed(mc,c:GetCode()) and c:IsAbleToHand()
end
function c19000073.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19000073.cfilter1,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c19000073.activate1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,c19000073.cfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.ConfirmCards(tp,g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	if g:GetCount()>0 and Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT) then
		local mg=Duel.SelectMatchingCard(tp,c19000073.filter1,tp,LOCATION_DECK,0,1,1,nil,g:GetFirst())
		if mg:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			Duel.SendtoHand(mg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,mg)
		end
   end
end
function c19000073.cfilter2(c)
	return aux.IsCodeListed(c,19000072) and c:IsAbleToRemoveAsCost()
end
function c19000073.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19000073.cfilter2,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c19000073.cfilter2,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
	Duel.ConfirmCards(tp,g)
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function c19000073.tgfilter(c)
	return c:IsCode(19000069) and c:IsAbleToGrave()
end
function c19000073.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19000073.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c19000073.activate2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c19000073.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
