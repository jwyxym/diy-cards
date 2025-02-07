--燃尽的爱神
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,72600560) 
	--active
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DISABLE+CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCost(s.cost2)
	c:RegisterEffect(e2)
end
function s.cfilter1(c,tp)
	return c:IsCode(72600200) and (c:IsControler(tp) or c:IsFaceup())
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter1,3,nil) end
	local g=Duel.SelectReleaseGroup(tp,s.cfilter1,3,3,nil)
	Duel.Release(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.actfilter(c,tp)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re)
		and Duel.IsExistingMatchingCard(s.actfilter,tp,0,LOCATION_MZONE,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local g=Duel.SelectMatchingCard(tp,s.actfilter,tp,0,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		end
	end
end
function s.cfilter2(c,tp)
	return aux.IsCodeListed(c,72600560) and c:IsType(TYPE_XYZ) and (c:IsControler(tp) or c:IsFaceup())
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter2,1,nil) end
	local g=Duel.SelectReleaseGroup(tp,s.cfilter2,1,1,nil)
	Duel.Release(g,REASON_COST)
end
