--军贯海图
function c35100294.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,35100294+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c35100294.atktg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
    --search
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1)
    e3:SetRange(LOCATION_SZONE)
	e3:SetCost(c35100294.scost)
	e3:SetTarget(c35100294.stg)
	e3:SetOperation(c35100294.sop)
	c:RegisterEffect(e3)
    --to hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(35100294,1))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,35100294)
	e4:SetCost(c35100294.thcost)
	e4:SetTarget(c35100294.thtg)
	e4:SetOperation(c35100294.thop)
	c:RegisterEffect(e4)
end
function c35100294.atktg(e,c)
	return c:IsSetCard(0x166)
end
function c35100294.scost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function c35100294.cfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and Duel.IsExistingMatchingCard(c35100294.thfilter,tp,LOCATION_DECK,0,1,nil,c) and not c:IsPublic()
end
function c35100294.thfilter1(c,rc)
	return c:IsSetCard(0x166) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsOriginalCodeRule(rc:GetOriginalCodeRule())
end
function c35100294.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(c35100294.cfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,c35100294.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	e:SetLabelObject(g:GetFirst())
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c35100294.sop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local rc=e:GetLabelObject()
	local g=Duel.SelectMatchingCard(tp,c35100294.thfilter1,tp,LOCATION_DECK,0,1,1,nil,rc)
    local tc=g:GetFirst()
    if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
        Duel.Damage(tp,tc:GetDefense(),REASON_EFFECT)
    end
end
function c35100294.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c35100294.geffilter(c)
	return c:IsCode(24639891) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function c35100294.thfilter(c)
	return c:IsSetCard(0x166) and c:IsType(TYPE_MONSTER)
     and (c:IsCode(24639891) or Duel.IsExistingMatchingCard(c35100294.geffilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)) and c:IsAbleToHand()
end
function c35100294.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c35100294.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c35100294.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c35100294.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end