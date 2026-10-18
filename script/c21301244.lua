--极点出发
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,21301247)
	--特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.dspcon)
	e1:SetTarget(s.dsptg)
	e1:SetOperation(s.dspop)
	c:RegisterEffect(e1)
	--特殊召唤    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,21301247)
	e2:SetCondition(s.gspcon)
	e2:SetTarget(s.gsptg)
	e2:SetOperation(s.gspop)
	c:RegisterEffect(e2)
end
function s.confilter(c)
	return c:IsFaceup() and aux.IsCodeListed(c,21301247) and (c:IsLocation(LOCATION_MZONE) or c:IsCode(21301247))
end
function s.dspcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.dspfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and aux.IsCodeListed(c,21301247) 
end
function s.dsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.dspfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.dspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.dspfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.gspcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function s.gspfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
    	and (aux.IsCodeListed(c,21301247) or (c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)))
end
function s.gsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.gspfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.gspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.gspfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end