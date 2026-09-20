--外宇宙袭击者★永恒灭杀之翼-残虐的冈格利佩拉IV型
local s,id,o=GetID()
function s.initial_effect(c)
	--不用解放召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--特殊召唤    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e3:SetTarget(s.gsptg)
	e3:SetOperation(s.gspop)
	c:RegisterEffect(e3)       
end
function s.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and loc&(LOCATION_HAND|LOCATION_GRAVE)>0
    	and not Duel.IsPlayerAffectedByEffect(tp,id)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    if e:GetActivateLocation()==LOCATION_GRAVE then
    	e:SetLabel(100)
    else
    	e:SetLabel(0)
    end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
    	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
    if e:GetLabel()==100 then
   		local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(id)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,1)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
    end
end
function s.spfilter(c,e,tp,lvt)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(lvt)
end
function s.costfilter(c,tp)
	return not c:IsType(TYPE_LINK) and c:IsReleasable() and (c:IsLevelAbove(1) or c:IsRankAbove(1))
    	and (c:IsControler(tp) or c:IsFaceup())
end
function s.fselect(g,e,tp)
	local lv=g:GetSum(Card.GetLevel)
    local rk=g:GetSum(Card.GetRank)
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,lv+rk)
    	and Duel.GetMZoneCount(tp,g)>0
end		
function s.gsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rg=Duel.GetReleaseGroup(tp):Filter(s.costfilter,nil,tp)
	if chk==0 then return e:IsCostChecked() and rg:GetCount()>0
    	and rg:CheckSubGroup(s.fselect,1,rg:GetCount(),e,tp) end	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=rg:SelectSubGroup(tp,s.fselect,false,1,rg:GetCount(),e,tp)
	aux.UseExtraReleaseCount(sg,tp)
	Duel.Release(sg,REASON_COST)
    local og=Duel.GetOperatedGroup()
    local lv=og:GetSum(Card.GetLevel)
    local rk=og:GetSum(Card.GetRank)
    local lvt=lv+rk
	e:SetLabel(lvt)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_GRAVE)
end
function s.gspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp,e:GetLabel())
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end