--陨宇祀圣的熔火磐岩
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(this.spcon1)
	e1:SetTarget(this.sptg1)
	e1:SetOperation(this.spop1)
	c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id+1)
	e1:SetTarget(this.thtg)
	e1:SetOperation(this.thop)
	c:RegisterEffect(e1)
end
function this.cfilter1(c)
	return c:IsSetCard(0xa63) and not c:IsCode(11130024) and c:IsFaceup()
end
function this.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(this.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
function this.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function this.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function this.thfilter(c)
	return (c:IsSetCard(0xa63) or c:IsRace(RACE_ROCK) and c:IsLevelBelow(4)) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function this.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,5) end
end
function this.thop(e,tp,eg,ep,ev,re,r,rp)
    local flag=true
	if Duel.IsPlayerCanDiscardDeck(tp,5) then
		Duel.ConfirmDecktop(tp,5)
		local g=Duel.GetDecktopGroup(tp,5)
		if g:GetCount()>0 then
			Duel.DisableShuffleCheck()
			if g:IsExists(this.thfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local sg=g:FilterSelect(tp,this.thfilter,1,1,nil)
				if Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then flag=false end
				Duel.ConfirmCards(1-tp,sg)
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
                local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
                if tc then Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end
				Duel.ShuffleHand(tp)
				g:Sub(sg)
			end
			aux.PlaceCardsOnDeckBottom(tp,g,REASON_EFFECT)
		end
	end
    if flag then Duel.Draw(tp,1,REASON_EFFECT) end
end
