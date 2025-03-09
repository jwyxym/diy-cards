--莱欧斯小队队长 莱欧斯
function c31280202.initial_effect(c)
	--
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHAINING) 
	e1:SetProperty(EFFECT_FLAG_DELAY) 
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetCountLimit(1,31280202)
	e1:SetCondition(c31280202.spcon) 
	e1:SetTarget(c31280202.sptg)
	e1:SetOperation(c31280202.spop)
	--c:RegisterEffect(e1)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetCountLimit(1,31280202)
	e1:SetCondition(c31280202.hspcon)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,21280202)
	e2:SetTarget(c31280202.thtg)
	e2:SetOperation(c31280202.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0) 
	e1:SetValue(1)
	e1:SetCondition(c31280202.idcon)
	--c:RegisterEffect(e1) 
	--pos
	local e2=Effect.CreateEffect(c) 
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,11280202)
	e2:SetCondition(c31280202.poscon) 
	e2:SetCost(c31280202.poscost)
	e2:SetTarget(c31280202.postg)
	e2:SetOperation(c31280202.posop)
	c:RegisterEffect(e2)
	if not c31280202.global_check then
		c31280202.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(c31280202.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
--c31280202.SetCard_TnT_Lwsteam=true 
function c31280202.checkop(e,tp,eg,ep,ev,re,r,rp) 
	local rc=re:GetHandler() 
	if rc:IsSetCard(0x3a22) and re:IsActiveType(TYPE_SPELL) and re:IsActiveType(TYPE_CONTINUOUS) and rp==tp then 
		Duel.RegisterFlagEffect(0,31280202,RESET_PHASE+PHASE_END,0,1) 
	end 
end
function c31280202.hspcon(e,c)
	if c==nil then return true end
	return Duel.GetFlagEffect(tp,31280202)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
end
function c31280202.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL) and re:IsActiveType(TYPE_CONTINUOUS) and re:GetHandler():IsSetCard(0x3a22) and rp==tp 
end 
function c31280202.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c31280202.filter(c)
	return not c:IsCode(31280202) and c:IsSetCard(0x3a21) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c31280202.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(c31280202.filter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(31280202,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,c31280202.filter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.BreakEffect()
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
function c31280202.idckfil(c) 
	return c:IsFaceup() and c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_SPELL) and c:IsSetCard(0x3a22) 
end 
function c31280202.idcon(e) 
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(c31280202.idckfil,tp,LOCATION_SZONE,0,1,nil)
end 
function c31280202.thfilter(c)
	return not c:IsCode(31280202) and c:IsSetCard(0x3a21) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c31280202.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280202.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c31280202.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c31280202.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c31280202.poscon(e,tp,eg,ep,ev,re,r,rp) 
	local ac=Duel.GetAttacker()
	return ac and ac:IsAttackAbove(1300) 
end
function c31280202.xctfil(c) 
	if c:IsLocation(LOCATION_HAND) then 
		return c:IsDiscardable() 
	else  
		return c:IsHasEffect(31280208)
	end 
end 
function c31280202.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c31280202.xctfil,tp,LOCATION_HAND+LOCATION_SZONE,0,nil)
	if chk==0 then return g:GetCount()>0 end 
	local tc=g:Select(tp,1,1,nil):GetFirst()  
	local te=tc:IsHasEffect(31280208) 
	if te then 
		te:UseCountLimit(tp) 
		Duel.SendtoDeck(tc,nil,2,REASON_COST)
	else 
		Duel.SendtoGrave(sg,REASON_COST+REASON_DISCARD)
	end 
end
function c31280202.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end 
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(e:GetHandler()) 
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0) 
end
function c31280202.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local tc=Duel.GetFirstTarget() 
	if c:IsRelateToEffect(e) and Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0 and tc:IsRelateToEffect(e) then 
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end 
end


