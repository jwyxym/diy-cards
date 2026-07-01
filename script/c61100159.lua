--三恶妖·魅灵兔
function c61100159.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61100159,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c61100159.e1cost)
	e1:SetTarget(c61100159.e1tg)
	e1:SetOperation(c61100159.e1op)
	c:RegisterEffect(e1)
end

function c61100159.e1cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end

function c61100159.e1tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsType(TYPE_MONSTER) 
end
	if chk==0 then return Duel.IsExistingTarget(aux.FilterBoolFunction(Card.IsType,TYPE_MONSTER),tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,aux.FilterBoolFunction(Card.IsType,TYPE_MONSTER),tp,0,LOCATION_MZONE,1,1,nil)
end
function c61100159.e1op(e,tp,eg,ep,ev,re,r,rp,code)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local code=tc:GetCode()
	local e1=Effect.CreateEffect(tc)
	e1:SetDescription(aux.Stringid(61100159,2)) 
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_EVENT_PLAYER+EFFECT_FLAG_CLIENT_HINT)
	e1:SetOperation(c61100159.efop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61100159,2)) 
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER+EFFECT_FLAG_CLIENT_HINT)
	e2:SetOperation(c61100159.efop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetTargetRange(0xff,0xff)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsCode,code))
	e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e3:SetLabelObject(e2)
	Duel.RegisterEffect(e3,tp)
end
function c61100159.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c61100159.e3tg)
	e1:SetOperation(c61100159.e3op)
	rc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(rc)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c61100159.e3tg)
	e2:SetOperation(c61100159.e3op)
	rc:RegisterEffect(e2)
end

function c61100159.e3tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
	end
end

function c61100159.e3op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
		Duel.GetControl(c,1-tp)
end