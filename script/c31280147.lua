--魔眼蛇神·梅杜莎
function c31280147.initial_effect(c)
	--融合素材
	c:EnableReviveLimit()
	aux.AddFusionProcCodeFun(c,31280146,c31280147.ffilter,1,true,true)
	--怪兽装备  
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31280147,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,31280147)
	e1:SetTarget(c31280147.target)
	e1:SetOperation(c31280147.operation)
	c:RegisterEffect(e1)
	--发动无效  
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31280147,1))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,31380146)
	e2:SetCondition(c31280147.condition1)
	e2:SetCost(c31280147.cost1)
	e2:SetTarget(c31280147.target1)
	e2:SetOperation(c31280147.operation1)
	c:RegisterEffect(e2)
	--墓地特召      
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31280147,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,31380147)
	e3:SetCondition(c31280147.condition2)
	e3:SetTarget(c31280147.target2)
	e3:SetOperation(c31280147.operation2)
	c:RegisterEffect(e3)
end    
function c31280147.ffilter(c)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_REPTILE)
end
function c31280147.eqfilter(c,tc,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCode(31280146) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function c31280147.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c31280147.eqfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,c,tp)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function c31280147.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c31280147.eqfilter),tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,c,tp)
		local sc=g:GetFirst()
		if sc and Duel.Equip(tp,sc,c) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetLabelObject(c)
			e1:SetValue(c31280147.eqlimit)
			sc:RegisterEffect(e1)
		end
	end
end
function c31280147.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function c31280147.condition1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function c31280147.costfilter(c)
	return c:IsFaceup() and c:IsCode(31280146) and c:GetOriginalType()&TYPE_MONSTER>0 and c:IsAbleToGraveAsCost()
end
function c31280147.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280147.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c31280147.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    local gc=g:GetFirst()
	Duel.SendtoGrave(gc,REASON_COST)
    gc:CreateEffectRelation(e)
	e:SetLabelObject(gc)
end
function c31280147.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function c31280147.operation1(e,tp,eg,ep,ev,re,r,rp)
	local gc=e:GetLabelObject()
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and gc:IsRelateToEffect(e) 
    	and gc:IsOriginalCodeRule(31280148) and Duel.SelectYesNo(tp,aux.Stringid(31280147,3)) then
    	Duel.BreakEffect()
        Duel.Destroy(eg,REASON_EFFECT)
	end        
end
function c31280147.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
function c31280147.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCode(31280146)
end
function c31280147.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c31280147.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c31280147.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c31280147.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
    	local tc=g:GetFirst()
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetRange(LOCATION_MZONE)
			e1:SetTargetRange(0,LOCATION_MZONE)
			e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
			e1:SetValue(c31280147.atklimit)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
            if not tc:IsType(TYPE_EFFECT) then
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_ADD_TYPE)
				e2:SetValue(TYPE_EFFECT)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2,true)
			end                
		end            
	end
end
function c31280147.atklimit(e,c)
	return c:IsFaceup() and not c:IsCode(31280146)
end