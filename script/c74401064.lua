local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,74401085)

	aux.AddFusionProcFunRep(c,s.matfilter,3,true)

	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.remcon)
	e1:SetTarget(s.remtg)
	e1:SetOperation(s.remop)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.pfilter)
	c:RegisterEffect(e2)
end

function s.matfilter(c)
	return c:IsRace(RACE_ZOMBIE) and not c:IsType(TYPE_TOKEN) and c:IsLocation(LOCATION_MZONE)
end

function s.remcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
			or Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
			or Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
function s.remop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if hg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		g:Merge(hg:RandomSelect(tp,1))
	end
	if Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g:Merge(Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil))
	end
	if Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g:Merge(Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil))
	end
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end

function s.pfilter(e,c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,74401085)
end