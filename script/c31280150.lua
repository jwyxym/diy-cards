--斯忒诺
function c31280150.initial_effect(c)
	aux.AddCodeList(c,31280146)
	--手卡特召并装备
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(31280150,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,31280150)
	e1:SetCost(c31280150.cost)
	e1:SetTarget(c31280150.target)
	e1:SetOperation(c31280150.operation)
	c:RegisterEffect(e1)
	--自肃    
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c31280150.splimit)
	c:RegisterEffect(e2)
	--攻击下降    
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(31280150,1))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(c31280150.condition1)
	e3:SetTarget(c31280150.target1)
	e3:SetValue(-1000)
	c:RegisterEffect(e3)
end
function c31280150.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function c31280150.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280150.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,c31280150.cfilter,1,1,REASON_COST,e:GetHandler())
end
function c31280150.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c31280150.eqfilter(c,tp,mc)
	return c:IsCode(31280146) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function c31280150.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c31280150.eqfilter),tp,LOCATION_DECK,0,1,nil)
    	and Duel.SelectYesNo(tp,aux.Stringid(31280150,2)) then
        Duel.BreakEffect()
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c31280150.eqfilter),tp,LOCATION_DECK,0,1,1,nil,tp,c)	
    	local tc=g:GetFirst()
        if tc and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsFaceup()  
        	 and Duel.Equip(tp,tc,c) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetLabelObject(c)
			e1:SetValue(c31280150.eqlimit)
			tc:RegisterEffect(e1)
		end
	end
end
function c31280150.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function c31280150.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not (c:IsCode(31280146) or aux.IsCodeListed(c,31280146))
end
function c31280150.condition1(e)
	local tp=e:GetHandlerPlayer()
	local a,d=Duel.GetBattleMonster(tp)
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and a and d and (a:IsCode(31280146) or aux.IsCodeListed(a,31280146))
end
function c31280150.target1(e,c)
	local tp=e:GetHandlerPlayer()
	local a,d=Duel.GetBattleMonster(tp)
	return c==d
end