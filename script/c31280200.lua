--莱欧斯小队 玛露西尔
function c31280200.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_QUICK_O) 
	e1:SetCode(EVENT_FREE_CHAIN) 
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,31280200)
	e1:SetCondition(c31280200.spcon)
	e1:SetTarget(c31280200.sptg)
	e1:SetOperation(c31280200.spop)
	c:RegisterEffect(e1)
	--to hand 
	local e2=Effect.CreateEffect(c) 
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS) 
	e2:SetCode(EVENT_CHAIN_SOLVING)  
	e2:SetRange(LOCATION_MZONE) 
	e2:SetCondition(c31280200.thcon) 
	e2:SetOperation(c31280200.thop)
	c:RegisterEffect(e2)
	--negate
	local e3=Effect.CreateEffect(c) 
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,11280200)
	e3:SetCondition(c31280200.discon) 
	e3:SetCost(c31280200.discost)
	e3:SetTarget(c31280200.distg)
	e3:SetOperation(c31280200.disop)
	c:RegisterEffect(e3)
end
--c31280200.SetCard_TnT_Lwsteam=true 
function c31280200.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xca0) 
end
function c31280200.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c31280200.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c31280200.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c31280200.thfil(c) 
	return c:IsAbleToHand() and c:IsSetCard(0xca0) and c:IsType(TYPE_SPELL+TYPE_TRAP)  
end 
function c31280200.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.BreakEffect() 
		local b1=Duel.IsExistingMatchingCard(c31280200.thfil,tp,LOCATION_DECK,0,1,nil)
		local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,31280199,nil,TYPES_TOKEN_MONSTER,0,0,4,RACE_ILLUSION,ATTRIBUTE_LIGHT) 
		local xtable={aux.Stringid(31280200,3)} 
		if b1 then table.insert(xtable,aux.Stringid(31280200,1)) end 
		if b2 then table.insert(xtable,aux.Stringid(31280200,2)) end 
		local op=Duel.SelectOption(tp,table.unpack(xtable))+1 
		if xtable[op]==aux.Stringid(31280200,1) then 
			local sg=Duel.SelectMatchingCard(tp,c31280200.thfil,tp,LOCATION_DECK,0,1,1,nil) 
			Duel.SendtoHand(sg,tp,REASON_EFFECT) 
			Duel.ConfirmCards(1-tp,sg) 
		end 
		if xtable[op]==aux.Stringid(31280200,2) then 
			local token=Duel.CreateToken(tp,31280199) 
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)  
		end 
	end
end
function c31280200.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsSetCard(0xca1) and re:IsActiveType(TYPE_SPELL) and re:IsActiveType(TYPE_CONTINUOUS) and e:GetHandler():IsAbleToHand()
end 
function c31280200.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAbleToHand() and Duel.SelectEffectYesNo(tp,c,aux.Stringid(31280200,4)) then 
		Duel.Hint(HINT_CARD,0,31280200)  
		Duel.SendtoHand(c,nil,REASON_EFFECT) 
	end 
end 
function c31280200.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function c31280200.xctfil(c) 
	if c:IsLocation(LOCATION_HAND) then 
		return c:IsDiscardable() 
	else  
		return c:IsHasEffect(31280208)
	end 
end 
function c31280200.xctgck(g) 
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_SZONE) then 
		return g:GetCount()==1 
	else 
		return g:GetCount()==2
	end  
end 
function c31280200.discost(e,tp,eg,ep,ev,re,r,rp,chk) 
	local g=Duel.GetMatchingGroup(c31280200.xctfil,tp,LOCATION_HAND+LOCATION_SZONE,0,nil)
	if chk==0 then return g:CheckSubGroup(c31280200.xctgck,1,2) end 
	local sg=g:SelectSubGroup(tp,c31280200.xctgck,false,1,2) 
	if sg:GetCount()~=2 then 
		local tc=sg:GetFirst() 
		local te=tc:IsHasEffect(31280208) 
		if te then te:UseCountLimit(tp) end 
		Duel.SendtoDeck(tc,nil,2,REASON_COST)
	else 
		Duel.SendtoGrave(sg,REASON_COST+REASON_DISCARD)
	end 
end
function c31280200.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end  
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c31280200.desfil(c,tp) 
	return Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) 
end 
function c31280200.disop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(c31280200.desfil,tp,LOCATION_MZONE,0,1,nil,tp) and Duel.SelectYesNo(tp,aux.Stringid(31280200,0)) then 
		Duel.BreakEffect()
		local dg=Duel.SelectMatchingCard(tp,c31280200.desfil,tp,LOCATION_MZONE,0,1,1,nil,tp) 
		if Duel.Destroy(dg,REASON_EFFECT)~=0 then 
			local xdg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,dg) 
			Duel.Destroy(xdg,REASON_EFFECT)
		end 
	end
end
