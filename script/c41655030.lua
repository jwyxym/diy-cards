-- 烬雪的睥睨·格罗姆海尔
local s,id,o=GetID()
function s.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--分支1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)
	s.jinxue_effect=e1
	--分支2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
	--LP<0 时两个分支合并执行
	local e9=e1:Clone()
	e9:SetCondition(s.cannotcon)
	e9:SetOperation(s.operation3)
	c:RegisterEffect(e9)
	s.jinxue_effect=e9
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>=3
end
function s.thfilter(c)
	return c:IsCode(41655000) and c:IsAbleToHand()
end
function s.tdfilter(c)
	return c:IsSetCard(0xe93) and c:IsAbleToDeckAsCost()
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xe93) and c:IsType(TYPE_PENDULUM)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.posfilter(c)
	return c:IsCanTurnSet()
end
-- 分支1
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_PZONE,0,1,nil,e,tp)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	local gct=Duel.GetMatchingGroupCount(s.spfilter,tp,LOCATION_PZONE,0,nil,e,tp)
	if ct>gct then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,gct,tp,LOCATION_PZONE)
	else
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_PZONE)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_PZONE,0,nil,e,tp)
	local gc=g:GetCount()
	if gc==0 then return end
	local sg
	if gc<=ct then
		sg=g
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		sg=g:Select(tp,1,ct,nil)
	end
	if #sg==0 then return end
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
		for tc in aux.Next(sg) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetValue(s.efilter)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		Duel.SendtoHand(g2,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g2)
	end
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
-- 分支2
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,3,nil)
			and Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_HAND+LOCATION_ONFIELD)
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,3,3,nil)
	if g:GetCount()<3 then return end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local pg=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	if pg:GetCount()>0 then
		Duel.BreakEffect()
		Duel.ChangePosition(pg,POS_FACEDOWN_DEFENSE)
	end
end
function s.cannotcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(e:GetHandler())<0
end
function s.operation3(e,tp,eg,ep,ev,re,r,rp)
	s.operation1(e,tp,eg,ep,ev,re,r,rp)
	s.operation2(e,tp,eg,ep,ev,re,r,rp)
end