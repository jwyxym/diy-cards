--爱丽丝，疯狂国度的遗弃者
function c19991017.initial_effect(c)
	--change code
	aux.EnableChangeCode(c,19991003,LOCATION_DECK+LOCATION_REMOVED)
	--to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,19991017)
	e1:SetTarget(c19991017.thtg)
	e1:SetOperation(c19991017.thop)
	c:RegisterEffect(e1)
end
function c19991017.thfilter(c)
	return c:IsSetCard(0xb32) and c:IsAbleToHand()
end
function c19991017.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19991017.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c19991017.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c19991017.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
