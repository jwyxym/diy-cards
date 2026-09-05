--冰焰魔手
function c38030134.initial_effect(c)
	--spsummon-self
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38030134,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,38030134)
	e1:SetCost(c38030134.spcost)
	e1:SetTarget(c38030134.sptg)
	e1:SetOperation(c38030134.spop)
	c:RegisterEffect(e1)
	--level
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38030134,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,38030134+1)
	e2:SetTarget(c38030134.lvtg)
	e2:SetOperation(c38030134.lvop)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38030134,2))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_MOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,38030134+2)
	e3:SetCondition(c38030134.thcon)
	e3:SetTarget(c38030134.thtg)
	e3:SetOperation(c38030134.thop)
	c:RegisterEffect(e3)
end
function c38030134.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
function c38030134.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c38030134.spfilter(c,e,tp)
	return c:IsCode(95929069,68535320) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c38030134.spop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c38030134.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--
	local c=e:GetHandler()
	if not c:IsRelateToChain() or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	if Duel.IsExistingMatchingCard(c38030134.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.GetMZoneCount(tp)>0 and Duel.SelectYesNo(tp,aux.Stringid(38030134,2)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,c38030134.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function c38030134.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_EARTH)) and c:IsLocation(LOCATION_EXTRA)
end
function c38030134.tfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
function c38030134.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(c38030134.tfilter,tp,LOCATION_MZONE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c38030134.tfilter,tp,LOCATION_MZONE,0,2,2,nil)
	local ct=g:GetClassCount(Card.GetLevel)==1 and g:GetFirst():GetLevel() or 0
	Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
	e:SetLabel(Duel.AnnounceLevel(tp,1,10,ct))
end
function c38030134.lvop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetsRelateToChain()
	if #g==0 then return end
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function c38030134.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and c:IsPreviousLocation(LOCATION_OVERLAY)
		and re:IsActivated() and re:IsActiveType(TYPE_XYZ) and re:GetHandler():IsAttribute(ATTRIBUTE_EARTH)
end
function c38030134.thfilter(c)
	return c:IsCode(95929069,68535320) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c38030134.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c38030134.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c38030134.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c38030134.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
