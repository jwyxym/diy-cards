--333号-最后一曲
local s,id,o=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,11100110)
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL+EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.con)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(11100110)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,3,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function s.filter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil)
    local sg=Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT,LOCATION_REMOVED)
        if sg:GetCount()>0 then
            Duel.BreakEffect()
            Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
        end
	end
end