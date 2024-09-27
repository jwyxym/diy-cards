--尚未知晓的无垢湖光
function c76200509.initial_effect(c)
	aux.AddCodeList(c,76200500)
	--Activate 
	local e1=Effect.CreateEffect(c)  
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE) 
	e1:SetCode(EVENT_FREE_CHAIN)  
	e1:SetCountLimit(1,76200509)   
	e1:SetTarget(c76200509.actg) 
	e1:SetOperation(c76200509.acop) 
	c:RegisterEffect(e1) 
	--to hand 
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TOHAND) 
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,16200509) 
	e2:SetCondition(c76200509.thdcon)
	e2:SetTarget(c76200509.thdtg)
	e2:SetOperation(c76200509.thdop)
	c:RegisterEffect(e2)
end  
function c76200509.actg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local b1=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	local b2=Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and (aux.IsCodeListed(c,76200500) or c:IsCode(76200500)) end,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(function(c) return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON) and c:IsAbleToGraveAsCost() end,tp,LOCATION_EXTRA,0,1,nil) end  
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)  
end 
function c76200509.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local b1=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	local b2=Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and (aux.IsCodeListed(c,76200500) or c:IsCode(76200500)) end,tp,LOCATION_MZONE,0,1,nil)
	if Duel.IsExistingMatchingCard(function(c) return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON) and c:IsAbleToGrave() end,tp,LOCATION_EXTRA,0,1,nil) then 
		local sc=Duel.SelectMatchingCard(tp,function(c) return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON) and c:IsAbleToGrave() end,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
		if Duel.SendtoGrave(sc,REASON_EFFECT)~=0 and (b1 or b2) then 
			local xtable={}
			if b1 then table.insert(xtable,aux.Stringid(76200509,1)) end 
			if b2 then table.insert(xtable,aux.Stringid(76200509,2)) end 
			local op=Duel.SelectOption(tp,table.unpack(xtable))+1 
			if xtable[op]==aux.Stringid(76200509,1) then  
				local tc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil):GetFirst() 
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_ATTACK_FINAL)
				e1:SetRange(LOCATION_MZONE)
				e1:SetValue(0) 
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)   
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
				e1:SetRange(LOCATION_MZONE)
				e1:SetValue(0) 
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)		   
			end 
			if xtable[op]==aux.Stringid(76200509,2) then   
				local tc=Duel.SelectMatchingCard(tp,function(c) return c:IsFaceup() and (aux.IsCodeListed(c,76200500) or c:IsCode(76200500)) end,tp,LOCATION_MZONE,0,1,1,nil):GetFirst() 
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetRange(LOCATION_MZONE)
				e1:SetValue(sc:GetAttack()/2) 
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)   
			end 
		end 
	end 
end 
function c76200509.tckfil(c,tp) 
	return c:IsPreviousControler(tp) and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON) and c:IsReason(REASON_EFFECT) 
end 
function c76200509.thdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c76200509.tckfil,1,nil,tp)
end  
function c76200509.thdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end 
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)  
end
function c76200509.thdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT) 
	end
end







