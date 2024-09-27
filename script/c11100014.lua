--铁机龙战魔·三态警暴
local s,id=GetID()
function c11100014.initial_effect(c)
c:EnableReviveLimit()
	 aux.AddLinkProcedure(c,s.mfilter,2)
	  local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(s.descon1)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id+1000)
	e1:SetCondition(s.con2)
	e1:SetOperation(s.op2)
	c:RegisterEffect(e1)
local e3=e1:Clone()
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=Duel.GetMatchingGroup(Card.IsLinkSummonable,tp,LOCATION_EXTRA,0,nil,nil,c)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		sg=g:Select(tp,1,1,nil)
		Duel.LinkSummon(tp,sg:GetFirst(),nil,c)
	end
 local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sg:GetFirst():RegisterEffect(e1,true)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetHandler():GetSequence()
	local a
	local b
	 if seq==5 or seq==6 then
	 b=aux.MZoneSequence(seq) end
	if seq>0 then a=seq-1 end
	if seq<4 then b=seq+1 end
	return eg:IsExists(s.filter3,1,nil,tp,a,b) and not eg:IsContains(e:GetHandler())
end
function s.filter3(c,tp,a,b)
	return c:IsSetCard(0xa60) and c:IsType(TYPE_MONSTER) and c:IsControler(tp) and (c:GetSequence()==a or c:GetSequence()==b)
end
function s.mfilter(c)
	return c:IsSetCard(0xa60) and c:IsType(TYPE_LINK)
end
function s.filter(c)
	return c:IsSetCard(0xa60) and c:IsType(TYPE_MONSTER)
end
function s.descon1(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
	return sg:GetClassCount(Card.GetCode)>=3 and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetLinkedGroup()
	Duel.Destroy(mg,REASON_EFFECT)
	local ml=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	local zone=0
	zone=bit.bor(zone,c:GetLinkedZone())
	if zone>0 then
	Duel.SpecialSummon(ml,0,tp,tp,false,false,POS_FACEUP,zone)
 end
end








