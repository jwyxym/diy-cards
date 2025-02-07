--《生命·高塔》启示录
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.rfilter(c,e,tp,mg)
	local ct=0
	if c:IsLocation(LOCATION_PZONE) then
		ct=math.floor(c:GetOriginalLevel()/2)
	else
		ct=math.floor(c:GetLevel()/2)
	end
	if ct==0 then return false end
	return (c:GetOriginalType()&(TYPE_RITUAL+TYPE_MONSTER)==(TYPE_RITUAL+TYPE_MONSTER))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
		and mg:CheckSubGroup(s.gcheck,ct,ct,tp,c)
end
function s.gcheck(g,tp,fc)
	return Duel.GetMZoneCount(tp,g)>0 and not g:IsContains(fc)
		and g:FilterCount(Card.IsAbleToRemove,nil)==g:GetCount()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=0
	if Duel.IsPlayerAffectedByEffect(tp,51900303) then
		loc=LOCATION_GRAVE
	end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,loc,e:GetHandler())
	if chk==0 then return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_HAND+LOCATION_PZONE,0,1,nil,e,tp,g) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local loc=0
	if Duel.IsPlayerAffectedByEffect(tp,51900303) then
		loc=LOCATION_GRAVE
	end
	local mg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,loc,e:GetHandler())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_HAND+LOCATION_PZONE,0,1,1,nil,e,tp,mg)
	local tc=g:GetFirst()
	if tc then
		Duel.ConfirmCards(1-tp,tc)
		local ct=math.floor(tc:GetLevel()/2)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=mg:SelectSubGroup(tp,s.gcheck,false,ct,ct,tp,tc)
		if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)~=0 and sg:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)~=0 then
			tc:SetMaterial(nil)
			Duel.BreakEffect()
			if Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP) then
				tc:CompleteProcedure()
			end
		end
	end
end
function s.thfilter(c)
	return c:IsAbleToRemoveAsCost()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) and e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
		Duel.DiscardDeck(tp,2,REASON_EFFECT)
	end
end