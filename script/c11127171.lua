--古遗华彩·永瞬绿洲
function c11127171.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c11127171.activate)
	c:RegisterEffect(e1) 
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0) 
	e2:SetTarget(function(e,c) 
	return c:IsSetCard(0xa62) and c:IsLevelBelow(4) end)
	e2:SetValue(function(e)  
	local x=Duel.GetFieldGroupCount(0,LOCATION_REMOVED,LOCATION_REMOVED)*200
	if x>1600 then x=1600 end
	return x end)
	c:RegisterEffect(e2) 
	local e3=e2:Clone() 
	e3:SetCode(EFFECT_UPDATE_DEFENSE) 
	c:RegisterEffect(e3) 
	--negate
	local e3=Effect.CreateEffect(c) 
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O) 
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_DELAY) 
	e3:SetRange(LOCATION_FZONE) 
	e3:SetCountLimit(1,11127171) 
	e3:SetCondition(c11127171.negcon) 
	e3:SetTarget(c11127171.negtg)
	e3:SetOperation(c11127171.negop)
	c:RegisterEffect(e3)
end
function c11127171.thfil(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xa62) and c:IsAbleToHand()
end
function c11127171.rmfil(c)
	return c:IsRace(RACE_INSECT+RACE_PLANT) and c:IsAbleToRemove()
end
function c11127171.activate(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(c11127171.thfil,tp,LOCATION_DECK,0,1,nil) 
	local b2=Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsLevelAbove(5) and c:IsType(TYPE_FUSION) and c:IsSetCard(0xa62) end,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(c11127171.rmfil,tp,LOCATION_DECK,0,1,nil) 
	local xtable={aux.Stringid(11127171,3)} 
	if b1 then table.insert(xtable,aux.Stringid(11127171,1)) end 
	if b2 then table.insert(xtable,aux.Stringid(11127171,2)) end 
	local op=Duel.SelectOption(tp,table.unpack(xtable))+1 
	if xtable[op]==aux.Stringid(11127171,1) then 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=Duel.SelectMatchingCard(tp,c11127171.thfil,tp,LOCATION_DECK,0,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end 
	if xtable[op]==aux.Stringid(11127171,2) then 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg=Duel.SelectMatchingCard(tp,c11127171.rmfil,tp,LOCATION_DECK,0,1,1,nil)
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end 
end
function c11127171.nckfil(c,tp) 
	return c:IsPreviousControler(tp) and c:IsLevelAbove(5) and c:IsType(TYPE_FUSION) and c:IsSetCard(0xa62)  
end 
function c11127171.negcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c11127171.nckfil,1,nil,tp) 
end 
function c11127171.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end 
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_ONFIELD)
end
function c11127171.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil):GetFirst() 
	if tc and tc:IsFaceup() then
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
	end
end



