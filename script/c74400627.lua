local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.matfilter,3,99,s.matcheck)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.damtg)
	e1:SetCondition(s.damcon)
	e1:SetValue(DOUBLE_DAMAGE)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.matfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x74b)
end
function s.matcheck(g)
	return g:FilterCount(s.matfilter,nil)>=1
end
function s.damtg(e,c)
	return c:IsType(TYPE_LINK) and c:IsSetCard(0x74b)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttackTarget()~=nil
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x74b) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local lk=Duel.GetMatchingGroup(s.lkfilter,tp,LOCATION_EXTRA,0,nil,nil)
		if lk:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=lk:Select(tp,1,1,nil)
			Duel.LinkSummon(tp,sg:GetFirst(),nil)
		end
	end
end
function s.lkfilter(c)
	return c:IsType(TYPE_LINK) and c:IsSetCard(0x74b) and c:IsLinkSummonable(nil)
end
