--五色彩云
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,45205409)
	
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.costfilter1(c,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsControler(tp) and c:IsReleasableByEffect()
end

function s.costfilter2(c,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsControler(tp) and c:IsReleasableByEffect()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter1,tp,LOCATION_MZONE,0,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.costfilter2,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g1=Duel.SelectMatchingCard(tp,s.costfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g2=Duel.SelectMatchingCard(tp,s.costfilter2,tp,LOCATION_MZONE,0,1,1,nil,tp)
	g1:Merge(g2)
	Duel.Release(g1,REASON_COST)
end

function s.spfilter(c,e,tp)
	return c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local tc=g:GetFirst()
		if tc:IsCode(45205409) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(s.efilter)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end

function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

return s
