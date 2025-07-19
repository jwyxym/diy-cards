--黑童话萌素魔女
local s,id,o=GetID()
function s.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,6,2,s.ovfilter,aux.Stringid(id,0))
	--overlay
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.ovltg)
	e2:SetOperation(s.ovlop)
	c:RegisterEffect(e2)
	--xyzmat to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	--spsummon spell
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,5))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.spstg)
	e4:SetOperation(s.spsop)
	c:RegisterEffect(e4)
end

function s.ovfilter(c)
	return c:IsFaceup() and (c:IsCode(76200163) or (c:IsLevel(6) and c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_FUSION)))
end

function s.ovltgfilter(c)
	return c:IsSetCard(0x516) and c:IsType(TYPE_MONSTER)
end

function s.ovlxyzfilter(c)
	return c:IsType(TYPE_XYZ) and (c:IsRace(RACE_SPELLCASTER) or c:IsRace(RACE_ILLUSION))
end

function s.ovltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.ovltgfilter, tp, LOCATION_DECK,0,2,nil)
		and Duel.IsExistingMatchingCard(s.ovlxyzfilter, tp, LOCATION_MZONE,0,1,nil)
		and (c:CheckRemoveOverlayCard(tp, 1, REASON_EFFECT) 
		or Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,nil)) end
end

function s.ovlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local opt1 = c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
	local opt2 = Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,nil)

	local result=0
	if not opt1 and not opt2 then return end
	if opt1 and not opt2 then result=0 end
	if opt2 and not opt1 then result=1 end
	if opt1 and opt2 then result = Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4)) end
	if result==0 then
		result=c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	else
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DISCARD)
		result=Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT,nil)
	end

	if result>0 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
		local g = Duel.SelectMatchingCard(tp, s.ovlxyzfilter,tp,LOCATION_MZONE,0,1,1,nil)

		if g:GetCount()>0 then
			local matg = Duel.SelectMatchingCard(tp, s.ovltgfilter,tp,LOCATION_DECK,0,2,2,nil)
			if matg:GetCount() == 2 then
				Duel.Overlay(g:GetFirst(), matg)
			end
		end
	end
end
function s.thfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_SPELLCASTER)
		and c:IsAbleToHand() and c:GetOwner()==tp
end
function s.xfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRace(RACE_SPELLCASTER+RACE_ILLUSION)
		and c:GetOverlayGroup():IsExists(s.thfilter,1,nil,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.xfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.xfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_OVERLAY)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local mg=tc:GetOverlayGroup():Filter(s.thfilter,nil,tp)
	if tc:IsRelateToEffect(e) and #mg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local bc=mg:Select(tp,1,1,nil):GetFirst()
		if Duel.SendtoHand(bc,nil,REASON_EFFECT)>0
			and bc:IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,bc)
			Duel.ShuffleHand(tp)
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and bc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				and Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
				Duel.BreakEffect()
				Duel.SpecialSummon(bc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
function s.sfilter(c,e,tp)
	return c:IsLocation(LOCATION_SZONE) and c:GetOriginalType()&TYPE_MONSTER>0
		and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_SZONE,0,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
