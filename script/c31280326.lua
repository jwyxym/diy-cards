--深池-焦竭之火
function c31280326.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--公开手卡
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(31280326,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
  	e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,31280326)
	e2:SetTarget(c31280326.target)
	e2:SetOperation(c31280326.operation)
	c:RegisterEffect(e2)
	--仪式召唤
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(31280326,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
  	e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,31380326)
    e3:SetHintTiming(TIMING_END_PHASE)
    e3:SetCondition(c31280326.condition2)
	e3:SetTarget(c31280326.target2)
	e3:SetOperation(c31280326.operation2)
	c:RegisterEffect(e3)
	--除外或特召
    local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
  	e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,31380327)
    e4:SetCondition(c31280326.condition3)
	e4:SetTarget(c31280326.target3)
	e4:SetOperation(c31280326.operation3)
	c:RegisterEffect(e4)
end
function c31280326.filter1(c)
	return c:IsSetCard(0xca3) and c:IsType(TYPE_MONSTER)
end
function c31280326.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280326.filter1,tp,LOCATION_HAND,0,1,nil) end
	local g=Duel.GetMatchingGroup(c31280326.filter1,tp,LOCATION_HAND,0,nil)
end	
function c31280326.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,c31280326.filter1,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.ConfirmCards(1-tp,g)
		local sg=g:GetFirst()
		local e1=Effect.CreateEffect(sg)
		e1:SetDescription(66)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PUBLIC)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		sg:RegisterEffect(e1)
	end
    local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS) 
	e1:SetCode(EVENT_PHASE+PHASE_END) 
	e1:SetCountLimit(1) 
	e1:SetOperation(c31280326.operation1) 
	Duel.RegisterEffect(e1,tp)
end
function c31280326.filter2(c)
	return c:IsRace(RACE_DRAGON) and c:IsPublic()
end
function c31280326.filter3(c)
	return c:IsRace(RACE_DRAGON) and c:IsSetCard(0xca3)
end
function c31280326.operation1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c31280326.filter2,tp,LOCATION_HAND,0,nil) 
    local sg=Duel.GetMatchingGroup(c31280326.filter3,tp,LOCATION_MZONE,0,nil)
	if g and sg and g:GetCount()==0 and sg:GetCount()==0 then
	local gg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_MZONE,0,nil)
		if gg and gg:GetCount()>0 then
		Duel.Hint(HINT_CARD,0,31280326)
		Duel.SendtoGrave(gg,REASON_EFFECT)
		end
	end
	e:Reset() 
end 
function c31280326.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function c31280326.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK)
end
function c31280326.RitualUltimateFilter(c,filter,e,tp,m1,m2,level_function,greater_or_equal,chk)
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
function c31280326.target2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
		local mg1=Duel.GetRitualMaterial(tp)
        return Duel.IsExistingMatchingCard(c31280326.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,c31280326.filter,e,tp,mg1,nil,Card.GetLevel,"Greater") 
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c31280326.operation2(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
    local mg1=Duel.GetRitualMaterial(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c31280326.RitualUltimateFilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,c31280326.filter,e,tp,mg1,nil,Card.GetLevel,"Greater")
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
function c31280326.spfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and not c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_EFFECT)
end
function c31280326.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_RITUAL)
end
function c31280326.condition3(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31280326.spfilter,1,nil,tp) and Duel.IsExistingMatchingCard(c31280326.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c31280326.rmfilter(c,e,tp,check)
	return c:IsAttribute(ATTRIBUTE_DARK)
		and (c:IsAbleToRemove() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function c31280326.target3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c31280326.rmfilter(chkc,e,tp,check) end
	if chk==0 then return Duel.IsExistingTarget(c31280326.rmfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,check) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,c31280326.rmfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,check)
end
function c31280326.operation3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if aux.NecroValleyNegateCheck(tc) then return end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and (not tc:IsAbleToRemove() or Duel.SelectOption(tp,1192,1152)==1) then
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
           	local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)				
            e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)				
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
            local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CANNOT_ATTACK)
			e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3,true)
		else
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end