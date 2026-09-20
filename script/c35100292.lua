--鲜鱼子军贯
function c35100292.initial_effect(c)
	--change name
	aux.EnableChangeCode(c,61027400,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE)
    --search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35100292,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,35100292)
	e1:SetCost(c35100292.thcost)
	e1:SetTarget(c35100292.thtg)
	e1:SetOperation(c35100292.thop)
	c:RegisterEffect(e1)
    --spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35100292,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetCountLimit(1,35100293)
    e2:SetCondition(c35100292.spcon)
	e2:SetCost(c35100292.spcost1)
	e2:SetTarget(c35100292.sptg1)
	e2:SetOperation(c35100292.spop1)
	c:RegisterEffect(e2)
end
function c35100292.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
function c35100292.thfilter(c)
	return c:IsSetCard(0x166) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER) and not c:IsOriginalCodeRule(35100292)
end
function c35100292.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c35100292.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function c35100292.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c35100292.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleDeck(tp)
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if sg:GetCount()>0 then
			Duel.BreakEffect()
			Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end
function c35100292.spfilter(c,e,tp,mc)
	return c:IsSetCard(0x166) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c) and c:GetBaseDefense()==300
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function c35100292.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not (r==REASON_RULE)
end
function c35100292.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
function c35100292.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		and Duel.IsExistingMatchingCard(c35100292.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
    end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_EXTRA)
end
function c35100292.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
        if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,c35100292.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
        local sc=g:GetFirst()
            if sc then
                Duel.BreakEffect()
                sc:SetMaterial(Group.FromCards(c))
                Duel.Overlay(sc,Group.FromCards(c))
                Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
                sc:CompleteProcedure()
            end
        
    end
end