--清晶矿之世界
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.indescon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_REMOVE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(s.rmlimit)
	e3:SetCondition(s.indescon)
	c:RegisterEffect(e2)
	--to deck
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,id+1)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>3 end
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=3 then return end
	Duel.ConfirmDecktop(tp,4)
	local g=Duel.GetDecktopGroup(tp,4)
	local ct=g:GetCount()
	if ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:FilterCount(s.spfilter,nil,e,tp)>0
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.DisableShuffleCheck()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		ct=g:GetCount()-sg:GetCount()
	end
	if ct>0 then
		Duel.SortDecktop(tp,tp,ct)
		for i=1,ct do
			local mg=Duel.GetDecktopGroup(tp,1)
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x760)
end
function s.indescon(e)
	return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.rmlimit(e,c,tp,r,re)
	return c==e:GetHandler() and r&REASON_EFFECT>0
end
function s.negfilter(c)
	return (c:IsSetCard(0x760) or c:IsRace(RACE_ROCK)) and c:IsAbleToDeck() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.negfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.negfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tc,1,tp,tc:GetFirst():GetLocation())
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
