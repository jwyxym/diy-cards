--逐火之旅 诡计 浪漫
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,47700121)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.fdcon)
	e1:SetTarget(s.fdtg)
	e1:SetOperation(s.fdop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o*10000)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
function s.fdcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
function s.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x471,0x474)
		and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_EARTH+ATTRIBUTE_WIND)
end
function s.cfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x471,0x474)
		and c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_FIRE+ATTRIBUTE_WATER)
end
function s.fdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,1)
			and Duel.IsPlayerCanDraw(1-tp,1)
			and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil)
			or re:GetHandler():IsRelateToEffect(re)
			and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil)
	end
end
function s.fdop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsPlayerCanDraw(1-tp,1)
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil)
	local b2=re:GetHandler():IsRelateToEffect(re)
		and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil)
	if not (b1 or b2) then return end
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	if op==1 then
		local g=Group.CreateGroup()
		Duel.ChangeTargetCard(ev,g)
		Duel.ChangeChainOperation(ev,s.repop)
	elseif op==2 then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
	Duel.Draw(1-tp,1,REASON_EFFECT)
end
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x471) and c:IsAbleToDeck()
		and Duel.IsExistingMatchingCard(s.tdfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
end
function s.tdfilter2(c)
	return c:IsFaceupEx() and c:IsSetCard(0x473) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(tp,s.tdfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		g:Merge(g2)
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	end
end