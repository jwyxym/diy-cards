--
function c20010044.initial_effect(c)
	--synchro summon
	c:EnableReviveLimit()
	aux.AddSynchroMixProcedure(c,c20010044.matfilter1,nil,nil,aux.NonTuner(Card.IsSetCard,0xb33),1,99)
	--gain control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20010044,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,20010044)
	e1:SetTarget(c20010044.contg)
	e1:SetOperation(c20010044.conop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20010044,0))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,20010044)
	e2:SetCondition(c20010044.concon)
	e2:SetTarget(c20010044.contg)
	e2:SetOperation(c20010044.conop)
	c:RegisterEffect(e2)
	--draw
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20010044,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e3:SetCountLimit(1,20010044+100)
	e3:SetCost(c20010044.cost)
	e3:SetTarget(c20010044.target)
	e3:SetOperation(c20010044.operation)
	c:RegisterEffect(e3)
end
function c20010044.matfilter1(c,syncard)
	return (c:IsTuner(syncard) and c:IsSetCard(0xb33)) or c:IsSetCard(0xb33)
end
function c20010044.concon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return c:IsReason(REASON_COST) and rc:IsSetCard(0xb33) and re:IsActivated()
end
function c20010044.confilter(c)
	return c:IsControlerCanBeChanged()
end
function c20010044.contg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c20010044.confilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c20010044.confilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,c20010044.confilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function c20010044.conop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsType(TYPE_MONSTER) and tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp)
	end
end
function c20010044.costfilter(c)
	return c:IsCode(20010010) and c:IsAbleToRemoveAsCost()
end
function c20010044.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20010044.costfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c20010044.costfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c20010044.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c20010044.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end