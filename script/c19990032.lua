--
function c19990032.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c19990032.target)
	e1:SetOperation(c19990032.operation)
	c:RegisterEffect(e1)
	--Atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	--Equip limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c19990032.equiplimit)
	c:RegisterEffect(e3)
	--to hand1
	local e4=Effect.CreateEffect(c)
	e4:SetCountLimit(1,19990032+100)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetDescription(aux.Stringid(19990032,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCost(c19990032.thcost1)
	e4:SetTarget(c19990032.thtg)
	e4:SetOperation(c19990032.thop)
	c:RegisterEffect(e4)
	--to hand2
	local e5=Effect.CreateEffect(c)
	e5:SetCountLimit(1,19990032+100)
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetDescription(aux.Stringid(19990032,2))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_REMOVED)
	e5:SetCost(c19990032.thcost2)
	e5:SetTarget(c19990032.thtg)
	e5:SetOperation(c19990032.thop)
	c:RegisterEffect(e5)
end
function c19990032.equiplimit(e,c)
	return c:IsRace(RACE_BEAST)
end
function c19990032.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
function c19990032.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c19990032.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c19990032.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,c19990032.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function c19990032.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
function c19990032.costfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0xb29) and c:IsAbleToGraveAsCost()
end
function c19990032.thcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19990032.costfilter1,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c19990032.costfilter1,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function c19990032.costfilter2(c,tp)
	return c:IsSetCard(0xb29) and c:IsFaceup() and c:IsAbleToRemoveAsCost()
end
function c19990032.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19990032.costfilter2,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c19990032.costfilter2,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c19990032.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function c19990032.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end
