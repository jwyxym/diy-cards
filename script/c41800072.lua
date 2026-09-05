--王战的尘世
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--tohand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_RELEASE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.thfilter(c)
	return c:IsSetCard(0x134) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.spfilter(c,e,tp,tc)
	return c:IsSetCard(0x134) and not c:IsCode(tc:GetCode())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.cfilter(c,e,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) 
		and c:GetPreviousLevelOnField()==9 and c:IsPreviousSetCard(0x134) 
		and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,nil,e,tp,c)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.cfilter,nil,e,tp)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local tc=nil
	if #g==1 then
		tc=g:GetFirst()
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		tc=g:Select(tp,1,1,nil)
	end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tc,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) then return end
	if tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,1,nil,e,tp,tc)
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
			Duel.BreakEffect()
			Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end