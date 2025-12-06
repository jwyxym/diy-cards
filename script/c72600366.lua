--与非人少女的约定
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,72600351)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,s.mfilter,s.xyzcheck,2,2)
	--code
	aux.EnableChangeCode(c,72600351,LOCATION_MZONE+LOCATION_GRAVE)
	--to hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
function s.mfilter(c,xyzc)
	return c:IsXyzType(TYPE_MONSTER) and c:IsXyzLevel(xyzc,4)
end
function s.xyzcheck(g)
	return g:GetClassCount(Card.GetRace)==#g
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
function s.thfilter(c,e,tp)
	return (c:IsCode(72600351) or c:IsRace(RACE_AQUA+RACE_FISH)) and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false)) and c:IsFaceupEx()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) or not Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT) then return end
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
	if tc then
		if not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or Duel.SelectOption(tp,1190,1152)==0 then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
