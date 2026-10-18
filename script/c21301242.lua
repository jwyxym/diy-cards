--极北霜海之主 涅瑞伊斯
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,21301247)
	--同调召唤
	aux.AddSynchroMixProcedure(c,aux.Tuner(s.mfilter1),aux.Tuner(s.mfilter1),nil,aux.FilterBoolFunction(s.mfilter2),1,99)
	c:EnableReviveLimit()
	--特召限制	
    local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetValue(s.synlimit)
	c:RegisterEffect(e0)
	--贯穿伤害    
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetValue(DOUBLE_DAMAGE)
	c:RegisterEffect(e1)
	--特殊召唤    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,21301226)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--除外    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	--无效    
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.distg)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end
s.material_type=TYPE_SYNCHRO
function s.mfilter1(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsSynchroType(TYPE_SYNCHRO)
end
function s.mfilter2(c)
	return c:IsRace(RACE_DRAGON) and c:IsSynchroType(TYPE_SYNCHRO)
end
function s.synlimit(e,se,sp,st)
	return st&SUMMON_TYPE_SYNCHRO==SUMMON_TYPE_SYNCHRO and not se
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end    
function s.spfilter(c,e,tp)
	return ((c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_WATER)) or aux.IsCodeListed(c,21301247))
    	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
    	local sg=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=sg:Select(tp,1,1,nil):GetFirst()
			Duel.SynchroSummon(tp,sc,nil)
		end    	
	end
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil,tp,POS_FACEDOWN) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD+LOCATION_GRAVE)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil,tp,POS_FACEDOWN):GetFirst()
	if not tc then return end
    Duel.HintSelection(Group.FromCards(tc))
    if Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
    	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,21301243,0,TYPES_TOKEN_MONSTER,3000,3000,10,RACE_ROCK,ATTRIBUTE_WATER)
		local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,21301243,0,TYPES_TOKEN_MONSTER,3000,3000,10,RACE_ROCK,ATTRIBUTE_WATER,POS_FACEUP,1-tp)
    	if not b1 and not b2 then return end
    	if not Duel.SelectYesNo(tp,aux.Stringid(id,4)) then return end
        Duel.BreakEffect()
        local sel=0
        if b1 and b2 then
			sel=Duel.SelectOption(tp,aux.Stringid(id,5),aux.Stringid(id,6))
		elseif b2 then
			sel=1
		end
		local to=tp
		if sel==1 then to=1-tp end
        local token=Duel.CreateToken(tp,21301243)
		if Duel.SpecialSummonStep(token,0,tp,to,false,false,POS_FACEUP) then
        	local c=e:GetHandler()
			--全抗        
        	local e1=Effect.CreateEffect(c)
            e1:SetDescription(aux.Stringid(id,7))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetValue(s.efilter)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
			--不能改变形式 
            local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e2,true)          
        end
        Duel.SpecialSummonComplete()
    end
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sg=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return sg:GetCount()>0 end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,sg,1,0,0)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	if sg:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
		local tg=sg:Select(tp,1,1,nil)
		Duel.HintSelection(tg)
		local sc=tg:GetFirst()
		if not sc:IsCanBeDisabledByEffect(e) then return end
		Duel.NegateRelatedChain(sc,RESET_TURN_SET)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		sc:RegisterEffect(e3)
		if sc:IsType(TYPE_TRAPMONSTER) then
			local e4=e2:Clone()
			e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			sc:RegisterEffect(e4)
		end
	end
end