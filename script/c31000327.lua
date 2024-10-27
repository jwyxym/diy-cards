--腥红之血森
function c31000327.initial_effect(c)
	c:EnableCounterPermit(0x312)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c31000327.activate)
	c:RegisterEffect(e1)
	--counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c31000327.ctcon)
	e2:SetOperation(c31000327.ctop)
	c:RegisterEffect(e2)
	--avoid damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CHANGE_DAMAGE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,0)
	e3:SetCondition(c31000327.damcon)
	e3:SetValue(c31000327.damval)
	c:RegisterEffect(e3)
	local e33=e3:Clone()
	e33:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e33)
	--add counter
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetCondition(c31000327.damcon)
	e4:SetOperation(c31000327.ctop)
	c:RegisterEffect(e4)
	local e44=e4:Clone()
	e44:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e44)
end
function c31000327.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x312) and c:IsAbleToHand()
end
function c31000327.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c31000327.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(31000327,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c31000327.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function c31000327.splimit(e,c)
	return not (c:IsSetCard(0x312) or (c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_DARK))) and c:IsLocation(LOCATION_EXTRA)
end
function c31000327.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0
end
function c31000327.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x312,1)
end
function c31000327.damcon(e)
	return Duel.GetLP(e:GetHandlerPlayer())<=2000
end
function c31000327.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0 end
	return val
end