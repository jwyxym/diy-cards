--祸流巨蛇
function c31280157.initial_effect(c)
	--融合素材
	c:EnableReviveLimit()
	aux.AddFusionProcCodeRep(c,31280146,3,false,false)
	--额外特召
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31280157,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,31280157)
    e1:SetCondition(c31280157.condition)
    e1:SetCost(c31280157.cost)
	e1:SetTarget(c31280157.target)
	e1:SetOperation(c31280157.operation)
	c:RegisterEffect(e1)
	--改变卡名 
	aux.EnableChangeCode(c,31280146,LOCATION_GRAVE+LOCATION_SZONE,c31280157.condition1)	
	--守表攻击   
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DEFENSE_ATTACK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c31280157.target1)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--赋予效果
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_ADD_TYPE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(c31280157.target1)
	e4:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_REMOVE_TYPE)
	e5:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e5)
	--墓地特召
    local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(31280157,1))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e6:SetRange(LOCATION_GRAVE)
	e6:SetCountLimit(1,31380157)
	e6:SetCondition(c31280157.condition2)
    e6:SetCost(c31280157.cost2)
	e6:SetTarget(c31280157.target2)
	e6:SetOperation(c31280157.operation2)
	c:RegisterEffect(e6)
end
function c31280157.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function c31280157.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	Duel.PayLPCost(tp,2000)
end
function c31280157.spfilter(c,e,tp)
	return c:IsCode(31280157) and c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function c31280157.spfilter1(c,e,tp)
	return c:IsCode(31280157) and c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function c31280157.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		and Duel.IsExistingMatchingCard(c31280157.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c31280157.operation(e,tp,eg,ep,ev,re,r,rp)
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c31280157.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        tc:CompleteProcedure()
        if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c31280157.spfilter1),tp,LOCATION_EXTRA,0,1,nil,e,tp) 
        	and Duel.GetLP(tp)<=4000 and Duel.SelectYesNo(tp,aux.Stringid(31280157,2)) then
        	Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c31280157.spfilter1),tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
        	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)   
		end            
	end
end
function c31280157.condition1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetEquipTarget() or c:IsLocation(LOCATION_GRAVE)
end
function c31280157.target1(e,c)
	return c:IsRace(RACE_REPTILE)
end
function c31280157.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c31280157.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function c31280157.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c31280157.spfilter2(c,e,tp)
	return c:IsCode(31280146) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c31280157.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
    	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) 
        if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c31280157.spfilter2),tp,LOCATION_GRAVE,0,1,nil,e,tp) 
    		and Duel.GetLP(tp)<=4000 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(31280157,3)) then
       		Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
       		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c31280157.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
        	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)       
		end            
	end
end