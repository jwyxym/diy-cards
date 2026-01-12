--
function c19990046.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--to hand
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(19990046,1))
	e0:SetCategory(CATEGORY_TODECK)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCountLimit(1,19990046+200)
	e0:SetTarget(c19990046.tctg)
	e0:SetOperation(c19990046.tcop)
	c:RegisterEffect(e0)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19990046,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,19990046)
	e1:SetCondition(c19990046.spcon)
	e1:SetTarget(c19990046.sptg)
	e1:SetOperation(c19990046.spop)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,19990046+100)
	e2:SetTarget(c19990046.thtg)
	e2:SetOperation(c19990046.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
function c19990046.tctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function c19990046.tcop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function c19990046.cfilter(c)
	return c:IsSetCard(0xb29)
end
function c19990046.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c19990046.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
function c19990046.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c19990046.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function c19990046.thfilter(c,e,tp)
	if not (c:IsSetCard(0xb29) and c:IsType(TYPE_MONSTER)) then return false end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function c19990046.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19990046.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
function c19990046.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,c19990046.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		elseif ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
