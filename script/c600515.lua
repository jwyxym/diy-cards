--RAS·主唱LAYER
local s,id=GetID()
function s.initial_effect(c)
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xf09),3,99)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.dircon)
	e1:SetTarget(s.dirtg)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.immcon)
	e2:SetTarget(s.immtg)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(TIMING_END_PHASE)
	e4:SetCountLimit(1,id+id)
	e4:SetCondition(s.endcon)
	e4:SetCost(s.endcost)
	e4:SetTarget(s.endtg)
	e4:SetOperation(s.endop)
	--c:RegisterEffect(e4)
end
function s.dircon(e)
	local c=e:GetHandler()
	return c:GetMutualLinkedGroupCount()>0 and c:GetSequence()==2
end
function s.dirtg(e,c)
	return c:IsSetCard(0xf09)
end
function s.immcon(e)
	local c=e:GetHandler()
	return c:GetMutualLinkedGroupCount()>0 and c:GetSequence()==2
end
function s.immtg(e,c)
	return c:IsSetCard(0xf09)
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

-- 效果2: 特殊召唤目标
function s.costfilter(c,tp)
		return c:IsAbleToRemove() and (c:IsLocation(LOCATION_ONFIELD) or c:IsLocation(LOCATION_GRAVE))
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xf09) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local b1=Duel.IsExistingMatchingCard(Card.IsDestructable,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
		local b2=Duel.IsExistingMatchingCard(s.costfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil,tp)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
		return b1 or b2
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
 local b1=Duel.IsExistingMatchingCard(Card.IsDestructable,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
 local b2=Duel.IsExistingMatchingCard(s.costfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil,tp) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(id,2),1},{b2,aux.Stringid(id,3),2})
	local cost_success=false
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g1=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
		if #g1>0 then
			cost_success=Duel.Destroy(g1,REASON_EFFECT)>0
		end
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g2=Duel.SelectMatchingCard(tp,s.costfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil,tp,true)
		if #g2>0 then
			cost_success=Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)>0
		end
	end
	if cost_success and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.endcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end

function s.costfilter2(c,tp)
	return c:IsSetCard(0x5f09) and c:IsAbleToGraveAsCost()
end
function s.endcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter2,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter2,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	e:SetLabelObject(g:GetFirst())
	Duel.SendtoGrave(g,REASON_COST)
end

function s.tdfilter(c)
	return c:IsAbleToDeck()
end
function s.endtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		return g:GetCount()>0
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.endop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sent_card=e:GetLabelObject()
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=g:Select(tp,1,5,nil)
		if #sg>0 and Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
			if Duel.Draw(tp,1,REASON_EFFECT)>0 then
				local filter=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil,sent_card:GetCode(),e,tp)
				if #filter>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
					local tc=filter:Select(tp,1,1,nil):GetFirst()
					if tc:IsType(TYPE_MONSTER) then
						Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
						Duel.ConfirmCards(tp,tc)
					else
						Duel.SSet(tp,tc,tp)
					end
				end
			end
		end
	end
end
function s.setfilter(c,code,e,tp)
	if c:GetCode()==code and c:IsSetCard(0x5f09) then return false end
	if c:IsType(TYPE_MONSTER) then
		return not Duel.IsPlayerAffectedByEffect(tp,59822133)
			and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp)
	else
		return (Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0
			or c:IsType(TYPE_FIELD))
			and c:IsSSetable(true)
	end
end

