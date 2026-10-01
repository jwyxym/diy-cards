--义贼追随者
function c21363707.initial_effect(c)
	aux.AddCodeList(c,21363700)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,21363707) 
	e1:SetCost(c21363707.thcost)
	e1:SetTarget(c21363707.thtg)
	e1:SetOperation(c21363707.thop)
	c:RegisterEffect(e1)   
	--rsp
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,21363708) 
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c21363707.rsptg)
	e2:SetOperation(c21363707.rspop)
	c:RegisterEffect(e2)   
end
function c21363707.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end
function c21363707.thfil(c) 
	return c:IsAbleToHand() and aux.IsCodeListed(c,21363700) 
end 
function c21363707.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21363707.thfil,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function c21363707.thop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c21363707.thfil,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD,nil)
	end
end
function c21363707.spfil(c,e,tp) 
	return c:IsCode(21363700) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
end 
function c21363707.rsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c21363707.spfil,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK) 
end
function c21363707.rspop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil) 
	if rg:GetCount()>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c21363707.spfil,tp,LOCATION_DECK,0,1,nil,e,tp) then 
		local tc=Duel.SelectMatchingCard(tp,c21363707.spfil,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst() 
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) 
	end 
end 

