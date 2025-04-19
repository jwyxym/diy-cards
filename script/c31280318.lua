--红龙的镜中舞
function c31280318.initial_effect(c)
	--堆墓回手（未完成）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND+CATEGORY_TOGRAVE+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,31280318+EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(c31280318.condition)
	e1:SetCost(c31280318.cost)
	e1:SetTarget(c31280318.target)
	e1:SetOperation(c31280318.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(31280318,ACTIVITY_SPSUMMON,c31280318.counterfilter)
end
function c31280318.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_GRAVE) or c:IsSetCard(0xca3)
end
function c31280318.cfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0xca3)
end
function c31280318.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(c31280318.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c31280318.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(31280318,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c31280318.splimit)
	Duel.RegisterEffect(e1,tp)
end
function c31280318.splimit(e,c)
	return c:IsLocation(LOCATION_GRAVE) and not c:IsSetCard(0xca3)
end
function c31280318.filter(c)
	return c:IsSetCard(0xca3) and c:IsAbleToGrave() and c:IsType(TYPE_MONSTER)
end
function c31280318.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c31280318.filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280318.filter,tp,LOCATION_DECK,0,2,nil) 
    	and g:CheckSubGroup(aux.dabcheck,2,2) end	
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,2,tp,LOCATION_DECK)
end
function c31280318.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.GetMatchingGroup(c31280318.filter,tp,LOCATION_DECK,0,nil)
    local g1=g:SelectSubGroup(tp,aux.dabcheck,false,2,2)
	if g1:GetCount()>0 and Duel.SendtoGrave(g1,REASON_EFFECT)~=0 and Duel.SelectYesNo(tp,aux.Stringid(31280318,0)) then
		Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g1:FilterSelect(tp,c31280318.rmfilter,1,1,nil,tp)
		if #sg>0 then
			Duel.SendtoHand(sg,tp,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sg)
        	local cg=sg:GetFirst()
        	local e1=Effect.CreateEffect(cg)
			e1:SetDescription(66)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_PUBLIC)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			cg:RegisterEffect(e1)
		end  
 	end        
end
function c31280318.rmfilter(c)
	return c:IsAbleToHand()
end