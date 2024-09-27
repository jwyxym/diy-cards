--痛幻哭奏
function c72600211.initial_effect(c) 
	aux.AddCodeList(c,72600200) 
	--Activate
	local e1=Effect.CreateEffect(c) 
	e1:SetDescription(aux.Stringid(72600211,1)) 
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH) 
	e1:SetType(EFFECT_TYPE_ACTIVATE) 
	e1:SetCode(EVENT_FREE_CHAIN) 
	e1:SetCountLimit(1,72600211) 
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(72600200) end,tp,LOCATION_MZONE,0,1,nil)  end) 
	e1:SetTarget(c72600211.actg1) 
	e1:SetOperation(c72600211.acop1) 
	c:RegisterEffect(e1) 
	local e1=Effect.CreateEffect(c) 
	e1:SetDescription(aux.Stringid(72600211,2)) 
	e1:SetCategory(CATEGORY_DISABLE) 
	e1:SetType(EFFECT_TYPE_ACTIVATE) 
	e1:SetCode(EVENT_FREE_CHAIN) 
	e1:SetCountLimit(1,72600211) 
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(72600200) end,tp,LOCATION_MZONE,0,1,nil)  end) 
	e1:SetTarget(c72600211.actg2) 
	e1:SetOperation(c72600211.acop2) 
	c:RegisterEffect(e1)  
	--to grave
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c72600211.regop)
	c:RegisterEffect(e2)
end
function c72600211.tgfil(c)
	return aux.IsCodeListed(c,72600200) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
function c72600211.actg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c72600211.tgfil,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c72600211.thfilter(c,tp)
	return aux.IsCodeListed(c,72600200) and c:IsAbleToHand()
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
function c72600211.acop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c72600211.tgfil,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then 
		if Duel.SendtoGrave(g,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(c72600211.thfilter,tp,LOCATION_DECK,0,1,nil,tp) and Duel.SelectYesNo(tp,aux.Stringid(72600211,0)) then  
			Duel.BreakEffect() 
			local sg=Duel.SelectMatchingCard(tp,c72600211.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp) 
			Duel.SendtoHand(sg,tp,REASON_EFFECT) 
			Duel.ConfirmCards(1-tp,sg) 
		end 
	end
end
function c72600211.actg2(e,tp,eg,ep,ev,re,r,rp,chk) 
	local x=Duel.GetMatchingGroupCount(function(c) return c:IsFaceup() and c:IsType(TYPE_TOKEN) end,tp,LOCATION_MZONE,LOCATION_MZONE,nil) 
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) and x>0 end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_MZONE)
end 
function c72600211.acop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.SelectMatchingCard(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	local x=Duel.GetMatchingGroupCount(function(c) return c:IsFaceup() and c:IsType(TYPE_TOKEN) end,tp,LOCATION_MZONE,LOCATION_MZONE,nil) 
	if tc and tc:IsFaceup() then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2) 
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK) 
		e1:SetRange(LOCATION_MZONE) 
		e1:SetValue(-x*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function c72600211.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O) 
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,12600211)
	e1:SetCost(c72600211.setcost)
	e1:SetTarget(c72600211.settg)
	e1:SetOperation(c72600211.setop) 
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1) 
end 
function c72600211.setcost(e,tp,eg,ep,ev,re,r,rp,chk)   
	if chk==0 then return Duel.CheckLPCost(tp,1000) end  
	Duel.PayLPCost(tp,1000)
end
function c72600211.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function c72600211.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end



