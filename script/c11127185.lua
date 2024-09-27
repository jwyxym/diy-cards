--华世之师·时瞬观者
function c11127185.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunFunRep(c,function(c) return c:IsFusionType(TYPE_FUSION) and c:IsFusionSetCard(0xa62) end,function(c) return c:IsFusionSetCard(0xa62) and c:IsFusionType(TYPE_MONSTER) end,2,2,true) 
	--negate
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)  
	e1:SetCountLimit(1,11127185)
	e1:SetTarget(c11127185.negtg)
	e1:SetOperation(c11127185.negop)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0) 
	e2:SetTarget(function(e,c) 
	return c:IsSetCard(0xa62) end) 
	e2:SetValue(500) 
	c:RegisterEffect(e2)   
	--control
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O) 
	e3:SetCode(EVENT_REMOVE)  
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET) 
	e3:SetCountLimit(1,21127185) 
	e3:SetTarget(c11127185.cttg)
	e3:SetOperation(c11127185.ctop)
	c:RegisterEffect(e3)
end
function c11127185.negtg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local mg=e:GetHandler():GetMaterial() 
	local x1=mg:FilterCount(Card.IsRace,nil,RACE_INSECT)
	local x2=mg:FilterCount(Card.IsRace,nil,RACE_PLANT)
	if chk==0 then return x1>0 and Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,x1,nil) and x2>0 and Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsSetCard(0xa62) end,tp,LOCATION_REMOVED,0,1,nil) end 
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,x1,1-tp,LOCATION_ONFIELD) 
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,x2,tp,LOCATION_REMOVED)
end
function c11127185.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=e:GetHandler():GetMaterial() 
	local x1=mg:FilterCount(Card.IsRace,nil,RACE_INSECT)
	if x1>0 and Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,x1,nil) then 
		local sg=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,x1,x1,nil) 
		local tc=sg:GetFirst()  
		while tc do 
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE) 
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END) 
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=e1:Clone()
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc:RegisterEffect(e3)
		end 
		tc=sg:GetNext() 
		end 
		Duel.AdjustInstantly() 
		local mg=e:GetHandler():GetMaterial() 
		local x2=mg:FilterCount(Card.IsRace,nil,RACE_PLANT)
		if x2>0 and Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsSetCard(0xa62) end,tp,LOCATION_REMOVED,0,x2,nil) then 
			local sg=Duel.SelectMatchingCard(tp,function(c) return c:IsFaceup() and c:IsSetCard(0xa62) end,tp,LOCATION_REMOVED,0,x2,x2,nil) 
			Duel.SendtoDeck(sg,nil,2,REASON_EFFECT) 
		end 
	end
end
function c11127185.filter(c)
	return c:IsControlerCanBeChanged()
end
function c11127185.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c11127185.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c11127185.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,c11127185.filter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function c11127185.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end





