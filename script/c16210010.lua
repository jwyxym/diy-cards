--前庭怒焰-终焉之炎 焕花永不可知
local s,id,o=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--连接召唤
	aux.AddLinkProcedure(c,nil,3,3,s.lcheck)
	c:EnableReviveLimit()
	--多种族    
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_RACE)
	e0:SetRange(LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA)
	e0:SetValue(RACE_PLANT+RACE_PYRO)
--c:RegisterEffect(e0)
	--特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--手卡封锁    
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)
end
function s.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkRace)==g:GetCount()
    	and g:IsExists(Card.IsLinkRace,3,nil,RACE_SPELLCASTER+RACE_PYRO+RACE_PLANT)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.cfilter(c)
	return c:IsRace(RACE_PLANT+RACE_SPELLCASTER+RACE_PYRO) and c:IsAbleToRemove()
end
function s.fselect(g,tg)
	return tg:IsExists(Card.IsLink,1,nil,#g)
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsRace(RACE_PLANT+RACE_SPELLCASTER+RACE_PYRO)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	local tg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
    local _,maxlink=tg:GetMaxGroup(Card.GetLink)
	if chk==0 then
		if #tg==0 then return false end
		return cg:CheckSubGroup(s.fselect,1,maxlink,tg)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,cg,cg:GetCount(),0,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spfilter1(c,e,tp,lk)
	return s.spfilter(c,e,tp) and c:IsLink(lk)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	local tg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	local _,maxlink=tg:GetMaxGroup(Card.GetLink)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=cg:SelectSubGroup(tp,s.fselect,false,1,maxlink,tg)
	if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)~=0 then
		local lk=rg:GetCount()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lk)
		local tc=g:GetFirst()
		if not tc then return end
        tc:SetMaterial(nil)
        if Duel.SpecialSummon(tc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)~=0 then
        	tc:CompleteProcedure()     
		end            
	end
end
function s.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_HAND and re:IsActiveType(TYPE_MONSTER+TYPE_TRAP)
end