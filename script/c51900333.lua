--《生命·高塔》铜锡工坊
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,id+o*10000)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
end
function s.setfilter(c)
	return c:IsFaceupEx() and not c:IsCode(id) and c:IsSSetable()
		and c:GetType()==TYPE_TRAP
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	if ft>=2 then ft=2 end
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
		if sg:GetCount()>0 then
			Duel.SSet(tp,sg)
			local og=Duel.GetOperatedGroup()
			for tc in aux.Next(og) do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(aux.Stringid(id,1))
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)
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
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=0
	if Duel.IsPlayerAffectedByEffect(tp,51900303) then
		loc=LOCATION_GRAVE
	end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,loc,e:GetHandler())
	if chk==0 then return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_HAND+LOCATION_PZONE,0,1,nil,e,tp,g) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
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