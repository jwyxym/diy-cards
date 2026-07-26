--统音的安纳提玛
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,57300009)
	aux.AddLinkProcedure(c,nil,2,2,s.gcheck)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
end
function s.gilfilter(c)
	return aux.IsCodeListed(c,57300009)
end
function s.gcheck(g,lc)
	return g:IsExists(aux.IsCodeListed,1,nil,57300009)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.thfilter(c)
	return s.gilfilter(c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,c:GetCode())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local discard_count=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,nil):GetCount()
		if discard_count==0 then return false end
		local max_tokens=math.min(discard_count, Duel.GetLocationCount(tp,LOCATION_MZONE))
		return max_tokens>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,57300025,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_BEASTWARRIOR,ATTRIBUTE_WIND)
	end
	local max_discard=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,nil):GetCount()
	local max_zone=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local max_val=math.min(max_discard, max_zone)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,max_val,nil)
	local ct=#g
	e:SetLabel(ct)
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,0,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if ct<=0 then return end
	for i=1,ct do
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local token=Duel.CreateToken(tp,57300025)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
