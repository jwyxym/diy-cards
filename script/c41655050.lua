-- 烬雪的交织·薇缇雅
local s,id,o=GetID()
function s.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c,false)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.matfilter,3,true)
	aux.AddContactFusionProcedure(c,aux.FilterBoolFunction(Card.IsReleasable,REASON_SPSUMMON),LOCATION_MZONE,0,Duel.Release,REASON_SPSUMMON+REASON_MATERIAL)
	--move
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
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
	--to deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,10))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
function s.matfilter(c)
	return c:IsFusionSetCard(0xe93) or c:IsFusionType(TYPE_NORMAL)
end
function s.tgcfilter(c,tp)
	return c:GetSequence()==0 or c:GetSequence()==4 and c:IsControler(1-tp)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.tgcfilter,1,nil,tp)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>1 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,0,LOCATION_MZONE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,1-tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local sg=g:Select(1-tp,2,2,nil)
		Duel.HintSelection(sg)
		Duel.SendtoGrave(sg,REASON_RULE,1-tp)
	end
end
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0xe93) and bit.band(sumtp,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xe93) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tffilter(c)
	return c:IsSetCard(0xe93) and c:IsFaceup() and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.tdfilter2(c)
	return c:IsSetCard(0xe93) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) and Duel.IsExistingMatchingCard(s.tdfilter2,tp,LOCATION_HAND,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_EXTRA,0,1,nil) and Duel.IsExistingMatchingCard(s.tdfilter2,tp,LOCATION_HAND,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
	end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,s.tdfilter2,tp,LOCATION_HAND,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		local tc=sg:GetFirst()
		if tc then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,s.tdfilter2,tp,LOCATION_HAND,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tg=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_EXTRA,0,1,1,nil)
		if tg:GetCount()>0 then
			Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
