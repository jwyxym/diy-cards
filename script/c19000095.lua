--天降神火
function c19000095.initial_effect(c)
	c:EnableReviveLimit()
	--tohand
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(19000095,0))
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,19000095)
	e0:SetCost(c19000095.thcost)
	e0:SetTarget(c19000095.thtg)
	e0:SetOperation(c19000095.thop)
	c:RegisterEffect(e0)
	--Ritual Summon
	local e2=aux.AddRitualProcGreater2(c,c19000095.filter,LOCATION_HAND+LOCATION_GRAVE,nil,nil,true)
	e2:SetDescription(aux.Stringid(19000095,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e2:SetCountLimit(1,19000095)
	e2:SetCost(aux.bfgcost)
	c:RegisterEffect(e2)
end
function c19000095.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function c19000095.thfilter(c)
	return not c:IsCode(19000095) and bit.band(c:GetType(),0x81)==0x81 and (c:IsLevel(9) or c:IsLevel(6)) and aux.AtkEqualsDef(c) and c:IsAbleToHand()
end
function c19000095.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19000095.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c19000095.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c19000095.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c19000095.filter(c,e,tp,chk)
	return c:IsType(TYPE_RITUAL) and (not chk or c~=e:GetHandler()) and not c:IsCode(19000095)
end