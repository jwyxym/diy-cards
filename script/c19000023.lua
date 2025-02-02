--扭曲画布
function c19000023.initial_effect(c)
	c:SetUniqueOnField(1,0,19000023)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetDescription(aux.Stringid(19000023,0))
	e1:SetCost(c19000023.cost)
	e1:SetTarget(c19000023.target1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(19000023,1))
	e2:SetTarget(c19000023.target2)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetDescription(aux.Stringid(19000023,2))
	e3:SetTarget(c19000023.target3)
	c:RegisterEffect(e3)
	--
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_NORMAL))
	e4:SetCode(EFFECT_ADD_CODE)
	e4:SetValue(c19000023.value)
	c:RegisterEffect(e4)
	e1:SetLabelObject(e4)
	--
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_NORMAL))
	e5:SetCode(EFFECT_ADD_ATTRIBUTE)
	e5:SetValue(c19000023.value)
	c:RegisterEffect(e5)
	e2:SetLabelObject(e5)
	--
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0)
	e6:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_NORMAL))
	e6:SetCode(EFFECT_ADD_RACE)
	e6:SetValue(c19000023.value)
	c:RegisterEffect(e6)
	e3:SetLabelObject(e6)
	--salvage
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_TOHAND)
	e7:SetCountLimit(1)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_PHASE+PHASE_END)
	e7:SetRange(LOCATION_GRAVE)
	e7:SetCondition(c19000023.thcon)
	e7:SetCost(c19000023.thcost)
	e7:SetTarget(c19000023.thtg)
	e7:SetOperation(c19000023.thop)
	c:RegisterEffect(e7)
end
function c19000023.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)*(2/3)))
end
function c19000023.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local mc=Duel.AnnounceCard(tp,TYPE_MONSTER,OPCODE_ISTYPE)
	e:GetLabelObject():SetLabel(mc)
	e:GetHandler():SetHint(CHINT_CARD,mc)
end
function c19000023.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	local ac=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	e:GetLabelObject():SetLabel(ac)
	e:GetHandler():SetHint(CHINT_ATTRIBUTE,ac)
end
function c19000023.target3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:GetLabelObject():SetLabel(rc)
	e:GetHandler():SetHint(CHINT_RACE,rc)
end
function c19000023.value(e,c)
	return e:GetLabel()
end
function c19000023.thcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function c19000023.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)*(2/3)))
end
function c19000023.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function c19000023.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end