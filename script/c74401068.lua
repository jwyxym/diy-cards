local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,74401085)

	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.matfilter,3,true)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_ALL)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.cost)
	e2:SetTarget(s.attg)
	e2:SetOperation(s.attop)
	c:RegisterEffect(e2)
end

function s.matfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsLevelAbove(6)
end

function s.atkval(e,c)
	return c:IsFaceup() and c:IsControler(1-e:GetHandlerPlayer()) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end

function s.costfilter(c)
	return aux.IsCodeListed(c,74401085)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,3,nil)
	e:SetLabel(#g)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	end
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if ct<=0 then return end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	local atk=ct*500
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end