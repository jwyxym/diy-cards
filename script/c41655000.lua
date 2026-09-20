-- 烬雪的灾天
local s,id,o=GetID()
function s.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.tdcost)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	s.jinxue_effect=e1
	--splimit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetTarget(s.tdtg2)
	e3:SetOperation(s.tdop2)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	Duel.PayLPCost(tp,2000)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,nil,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,0,1,1,nil):GetFirst()
	if tc then
		local g2=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
		local g3=tc:GetColumnGroup()
		g2:Merge(g3)
		g2:AddCard(tc)
		Duel.SendtoDeck(g2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsType(TYPE_NORMAL) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function s.tdfilter(c,tp)
	return c:IsAbleToDeck() and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
function s.tdtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local ag=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,g)
		g:Merge(ag)
	end
	Duel.SetOperationInfo(0,HINTMSG_TODECK,g,#g,0,0)
end
function s.drcfilter(c,tp)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(1-tp)
end
function s.tdop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoDeck(Duel.GetTargetsRelateToChain(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	Duel.ShuffleDeck(tp)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(s.drcfilter,1,nil,tp) then return end 
	Duel.Draw(tp,1,REASON_EFFECT)
end
