local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddSetNameMonsterList(c,0x742)

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.ritfilter(c)
	return c:IsSetCard(0x742) and c:IsType(TYPE_RITUAL)
end
function s.mfilter1(c)
	return c:IsRace(RACE_ILLUSION)
end
function s.mfilter(c)
	return c:IsRace(RACE_ILLUSION) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg1=Duel.GetRitualMaterial(tp):Filter(s.mfilter1,tp)
		local mg2=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_REMOVED,0,1,nil,s.ritfilter,e,tp,mg1,mg2,Card.GetLevel,"Equal")
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	local mg1=Duel.GetRitualMaterial(tp):Filter(s.mfilter1,tp)
	local mg2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.mfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_REMOVED,0,1,1,nil,s.ritfilter,e,tp,mg1,mg2,Card.GetLevel,"Equal")
	local tc=g:GetFirst()
	if tc then
		local mg=mg1
		mg:Merge(mg2)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE+LOCATION_REMOVED)
		if #mat2>0 then
			Duel.HintSelection(mat2)
		end
		mat:Sub(mat2)
		Duel.ReleaseRitualMaterial(mat)
		Duel.SendtoDeck(mat2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
		if tc:IsCode(74400919) then
			Duel.BreakEffect()
			local g2=Duel.GetMatchingGroup(Card.IsType,1-tp,LOCATION_ONFIELD,0,nil,TYPE_SPELL+TYPE_TRAP)
			if g2:GetCount()>0 then
				Duel.Destroy(g2,REASON_EFFECT)
			end
		end
	end
end
function s.fcfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ILLUSION)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.fcfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.costfilter(c)
	return c:IsRace(RACE_ILLUSION) and c:IsAbleToRemoveAsCost()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():IsAbleToRemoveAsCost()
			and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g:AddCard(e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.thfilter(c)
	return aux.IsSetNameMonsterListed(c,0x742) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end