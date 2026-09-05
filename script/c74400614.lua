local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.matfilter,1,1)

	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.plcon)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
end
function s.matfilter(c)
	return c:IsSetCard(0x74b) and c:IsType(TYPE_MONSTER)
end
function s.plcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsSummonType(SUMMON_TYPE_LINK) then
		local lg1=Duel.GetLinkedGroup(tp,1,1)
		local lg2=Duel.GetLinkedGroup(1-tp,1,1)
		local lg=Group.CreateGroup()
		if lg1 then lg:Merge(lg1) end
		if lg2 then lg:Merge(lg2) end
		return lg:IsContains(c)
	end
	return true
end
function s.plfilter(c,tp)
	return c:IsCode(74400639)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.plfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
