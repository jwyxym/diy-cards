--混融之城
function c38030151.initial_effect(c)
	c:EnableCounterPermit(0x611)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--counter
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetOperation(aux.chainreg)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c38030151.ctcon)
	e2:SetOperation(c38030151.ctop)
	c:RegisterEffect(e2)
	--immune
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(c38030151.immcon)
	e3:SetValue(c38030151.efilter)
	c:RegisterEffect(e3)
	--to hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(38030151,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,38030151)
	e4:SetTarget(c38030151.thtg)
	e4:SetOperation(c38030151.thop)
	c:RegisterEffect(e4)
end
function c38030151.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x5616) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 and rp==tp
end
function c38030151.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x611,1)
end
function c38030151.immcon(e)
	return e:GetHandler():GetCounter(0x611)>=10
end
function c38030151.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function c38030151.thfilter(c,chk)
	return c:IsSetCard(0x5616) and c:IsAbleToHand() and (chk==0 or aux.NecroValleyFilter()(c))-- and c:IsFaceupEx() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c38030151.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c38030151.thfilter,tp,LOCATION_DECK,0,1,nil,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c38030151.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,c38030151.thfilter,tp,LOCATION_DECK,0,1,1,nil,1):GetFirst()
	if not tc then return end
	--Duel.HintSelection(Group.FromCards(tc))
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tc)
	--if not tc:IsLocation(LOCATION_HAND) or not Duel.SelectYesNo(tp,aux.Stringid(38030151,2)) then return end
end
