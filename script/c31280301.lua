--爱布拉娜·深池，“领袖”
function c31280301.initial_effect(c)
	aux.AddCodeList(c,31280326)
	c:EnableReviveLimit()
    --仪式召唤    
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(31280301,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
  	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetHintTiming(TIMING_MAIN_END)
    e1:SetCondition(c31280301.condition)
	e1:SetTarget(c31280301.target)
	e1:SetOperation(c31280301.operation)
	c:RegisterEffect(e1)
	--墓地特召    
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(31280301,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,31280301)
	e2:SetCondition(c31280301.condition1)
    e2:SetCost(c31280301.cost1)
	e2:SetTarget(c31280301.target1)
	e2:SetOperation(c31280301.operation1)
	c:RegisterEffect(e2)
    --解放升攻
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c31280301.condition2)
	e3:SetValue(700)
	c:RegisterEffect(e3)
    if not c31280301.global_check then
		c31280301.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_RELEASE)
        ge1:SetCondition(c31280301.checkcon)
		ge1:SetOperation(c31280301.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function c31280301.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and ((c:IsPublic() and c:IsLocation(LOCATION_HAND)) or c:IsLocation(LOCATION_MZONE))
end
function c31280301.filter(c,e,tp)
	return c:IsSetCard(0xca3) and not c:IsCode(31280301)
end
function c31280301.RitualUltimateFilter(c,filter,e,tp,m1,m2,level_function,greater_or_equal,chk)
	if bit.band(c:GetType(),0x81)~=0x81 or (filter and not filter(c,e,tp,chk)) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true,POS_FACEUP) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	if m2 then
		mg:Merge(m2)
	end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	else
		mg:RemoveCard(c)
	end
	local lv=level_function(c)
	aux.GCheckAdditional=aux.RitualCheckAdditional(c,lv,greater_or_equal)
	local res=mg:CheckSubGroup(aux.RitualCheck,1,lv,tp,c,lv,greater_or_equal)
	aux.GCheckAdditional=nil
	return res
end
function c31280301.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    if chk==0 then
		local mg1=Duel.GetRitualMaterial(tp)
        mg1:RemoveCard(c)
        return Duel.IsExistingMatchingCard(c31280301.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,c31280301.filter,e,tp,mg1,nil,Card.GetLevel,"Greater") 
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c31280301.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	::cancel::
    local mg1=Duel.GetRitualMaterial(tp)
    mg1:RemoveCard(c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c31280301.RitualUltimateFilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,c31280301.filter,e,tp,mg1,nil,Card.GetLevel,"Greater")
	local tc=g:GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
function c31280301.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousControler(tp) and c:IsSetCard(0xca3) and c:IsReason(REASON_EFFECT)
end
function c31280301.condition1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31280301.cfilter,1,nil,tp)
end
function c31280301.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1400) end
	Duel.PayLPCost(tp,1400)
end
function c31280301.spfilter(c,e,tp)
	return c:IsSetCard(0xca3) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_RITUAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.DrytronSpSummonType(c))
end
function c31280301.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c31280301.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c31280301.operation1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c31280301.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	Duel.SpecialSummon(g,0,tp,tp,false,aux.DrytronSpSummonType(tc),POS_FACEUP_DEFENSE)
end
function c31280301.checkfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSummonLocation(LOCATION_GRAVE)
end
function c31280301.checkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31280301.checkfilter,1,nil,tp)
end
function c31280301.checkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(0,31280301,RESET_PHASE+PHASE_END,0,1)
end
function c31280301.condition2(e)
	return Duel.GetFlagEffect(0,31280301)>0
end