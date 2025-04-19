--红龙的死火
function c31280320.initial_effect(c)
	--苏生仪式
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCountLimit(1,31280320+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c31280320.condition)
	e1:SetTarget(c31280320.target)
	e1:SetOperation(c31280320.activate)
	c:RegisterEffect(e1)
end
function c31280320.cfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function c31280320.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31280320.cfilter,1,nil,tp) 
end

function c31280320.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,aux.DrytronSpSummonType(c),POS_FACEUP) and c:IsType(TYPE_MONSTER)
end
function c31280320.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c31280320.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c31280320.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c31280320.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c31280320.filter(c,e,tp)
	return c:IsSetCard(0xca3) and c:IsAttribute(ATTRIBUTE_DARK)
end
function c31280320.RitualUltimateFilter(c,filter,e,tp,m1,m2,level_function,greater_or_equal,chk)
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
function c31280320.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,aux.DrytronSpSummonType(tc),POS_FACEUP)>0 then
		::cancel::
    	local mg1=Duel.GetRitualMaterial(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c31280320.RitualUltimateFilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,c31280320.filter,e,tp,mg1,nil,Card.GetLevel,"Greater")
		local tg=g:GetFirst()
		if tg then
        	Duel.BreakEffect()
			local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tg,tg)
			if tg.mat_filter then
				mg=mg:Filter(tc.mat_filter,tg,tp)
			else
				mg:RemoveCard(tg)
			end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			aux.GCheckAdditional=aux.RitualCheckAdditional(tg,tg:GetLevel(),"Greater")
			local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tg:GetLevel(),tp,tg,tg:GetLevel(),"Greater")
			aux.GCheckAdditional=nil
			if not mat then goto cancel end
			tc:SetMaterial(mat)
			Duel.ReleaseRitualMaterial(mat)
			Duel.BreakEffect()
			Duel.SpecialSummon(tg,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end