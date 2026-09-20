-- 烬雪的狐狩·稔华
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
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32710364,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
function s.tdfilter(c,tp)
	return c:IsSetCard(0xe93) and c:IsAbleToDeck() and Duel.IsExistingTarget(s.cfilter2,tp,LOCATION_SZONE,LOCATION_SZONE,1,c)
end
function s.tdfilter2(c)
	return c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_SZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local ag=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,g)
	Duel.SetOperationInfo(0,HINTMSG_TODECK,g+ag,2,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoDeck(Duel.GetTargetsRelateToChain(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0xe93) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function s.filter(c,e,sp)
	return c:IsFaceup() and (c:IsSetCard(0xe93) or c:IsType(TYPE_NORMAL)) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter2,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_PZONE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	local gct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_PZONE,0,nil,e,tp)
	if ct>gct then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,gct,tp,LOCATION_PZONE)
	else
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_PZONE)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tg=Duel.SelectMatchingCard(tp,s.tdfilter2,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,tg)
	if Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ct<=0 then return end
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_PZONE,0,nil,e,tp)
		local gc=g:GetCount()
		if gc==0 then return end
		if gc<=ct then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,ct,ct,nil)
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
