--恶魔世界的闪光
function c21362804.initial_effect(c)
	aux.AddCodeList(c,21362800)
	--pendulum set
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,21362804) 
	e1:SetTarget(c21362804.pctg)
	e1:SetOperation(c21362804.pcop)
	c:RegisterEffect(e1)
	--ctde 
	local e2=Effect.CreateEffect(c)  
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e2:SetCountLimit(1,11362804) 
	e2:SetCost(c21362804.ctdcost)
	e2:SetTarget(c21362804.ctdtg)
	e2:SetOperation(c21362804.ctdop)
	c:RegisterEffect(e2)
end
function c21362804.pcfilter(c)
	return c:IsCode(21362800) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function c21362804.spfil(c,e,tp) 
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)  
end 
function c21362804.pctg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local b1=(Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and Duel.IsExistingMatchingCard(c21362804.pcfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil) 
	local xg=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:GetAttack()>0 end,tp,LOCATION_MZONE,LOCATION_MZONE,nil):Filter(aux.NegateEffectMonsterFilter,nil) 
	local b2=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,nil,21362800) and xg:GetCount()>0 
	if chk==0 then return b1 or b2 end 
end
function c21362804.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local b1=(Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and Duel.IsExistingMatchingCard(c21362804.pcfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil) 
	local xg=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:GetAttack()>0 end,tp,LOCATION_MZONE,LOCATION_MZONE,nil):Filter(aux.NegateEffectMonsterFilter,nil)  
	local b2=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,nil,21362800) and xg:GetCount()>0 
	if b1 or b2 then 
		if b2 then  
			local tc=xg:Select(tp,1,1,nil):GetFirst() 
			if tc then 
				Duel.NegateRelatedChain(tc,RESET_TURN_SET)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_ATTACK_FINAL)
				e1:SetRange(LOCATION_MZONE) 
				e1:SetValue(0)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
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
			end 
		else   
			local tc=Duel.SelectMatchingCard(tp,c21362804.pcfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil):GetFirst()
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)  
		end 
	end
end
function c21362804.ctdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_COST) 
end
function c21362804.cspfil(c,e,tp)
	return c:IsSetCard(0xba38) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c21362804.ctdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c21362804.cspfil,tp,LOCATION_GRAVE,0,1,nil,e,tp) end 
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE) 
end
function c21362804.ctdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.SelectMatchingCard(tp,c21362804.cspfil,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst() 
	if tc and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then 
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) 
	end 
end





