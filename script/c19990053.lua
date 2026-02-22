--
function c19990053.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--2X material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_DOUBLE_XMATERIAL)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(19990053)
	e0:SetCountLimit(1,19990053+200)
	c:RegisterEffect(e0)
	--to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19990053,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,19990053)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c19990053.thcon)
	e1:SetTarget(c19990053.thtg)
	e1:SetOperation(c19990053.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19990053,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,19990053)
	e3:SetCondition(c19990053.spcon)
	e3:SetTarget(c19990053.sptg)
	e3:SetOperation(c19990053.spop)
	c:RegisterEffect(e3)
end
function c19990053.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0xb29)
end
function c19990053.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19990053.cfilter,1,nil,tp)
end
function c19990053.rthfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xb29) and c:IsAbleToHand()
end
function c19990053.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and c19990053.rthfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c19990053.rthfilter,tp,LOCATION_PZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c19990053.rthfilter,tp,LOCATION_PZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c19990053.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function c19990053.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function c19990053.filter(c,tp)
	return c:IsSetCard(0xb29,0xb30) and c:IsFaceupEx() and c:IsAbleToDeck()
end
function c19990053.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c19990053.filter(chkc,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	if chk==0 then return Duel.IsExistingTarget(c19990053.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler(),tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c19990053.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,e:GetHandler(),tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c19990053.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end