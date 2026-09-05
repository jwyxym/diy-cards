--混沌手
function c38030130.initial_effect(c)
	aux.AddCodeList(c,38030130)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38030130,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,38030130)
	e1:SetCost(c38030130.spcost)
	e1:SetTarget(c38030130.sptg)
	e1:SetOperation(c38030130.spop)
	c:RegisterEffect(e1)
	--equip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38030130,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,38030130+1)
	e2:SetTarget(c38030130.eqtg)
	e2:SetOperation(c38030130.eqop)
	c:RegisterEffect(e2)
end
function c38030130.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_EXTRA,0,1,nil,63746411) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_EXTRA,0,1,1,nil,63746411)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function c38030130.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c38030130.thfilter(c)
	return aux.IsCodeListed(c,38030130) and c:IsAbleToHand()
end
function c38030130.spop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c38030130.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--
	local c=e:GetHandler()
	if not c:IsRelateToChain() or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	if not Duel.IsExistingMatchingCard(c38030130.thfilter,tp,LOCATION_DECK,0,1,nil) or not Duel.SelectYesNo(tp,aux.Stringid(38030130,2)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,c38030130.thfilter,tp,LOCATION_DECK,0,1,1,nil,1):GetFirst()
	if not tc then return end
	--Duel.HintSelection(Group.FromCards(tc))
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tc)
end
function c38030130.splimit(e,c)
	return not (c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_EARTH)) and c:IsLocation(LOCATION_EXTRA)
end
function c38030130.eqfilter(c,e,tp)
	return c:IsSetCard(0x48) and c:IsRankBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c38030130.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c38030130.eqfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and Duel.GetSZoneCount(tp)>0
		and Duel.IsExistingTarget(c38030130.eqfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectTarget(tp,c38030130.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function c38030130.eqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.BreakEffect()
		if not Duel.Equip(tp,c,tc) then return end
		--equip limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(c38030130.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
function c38030130.eqlimit(e,c)
	return c==e:GetLabelObject()
end
