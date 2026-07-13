--古代传说·最终的魔界
function c21362821.initial_effect(c)
	aux.AddCodeList(c,21362800)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,21362821)
	e1:SetTarget(c21362821.target)
	e1:SetOperation(c21362821.activate)
	c:RegisterEffect(e1) 
	--pl
	local e2=Effect.CreateEffect(c) 
	e2:SetType(EFFECT_TYPE_IGNITION) 
	e2:SetRange(LOCATION_GRAVE+LOCATION_REMOVED) 
	e2:SetTarget(c21362821.pltg)
	e2:SetOperation(c21362821.plop)
	c:RegisterEffect(e2)
end
function c21362821.filter(c)
	return c:IsSetCard(0xba38) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c21362821.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21362821.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c21362821.activate(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,c21362821.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then 
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc) 
		if not Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(21362800) end,tp,LOCATION_PZONE,0,1,nil) then 
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetTarget(c21362821.sumlimit)
			e1:SetLabel(tc:GetCode())
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			Duel.RegisterEffect(e2,tp)
			local e3=e1:Clone()
			e3:SetCode(EFFECT_CANNOT_MSET)
			Duel.RegisterEffect(e3,tp)
			local e4=e1:Clone()
			e4:SetCode(EFFECT_CANNOT_ACTIVATE)
			e4:SetValue(c21362821.aclimit)
			Duel.RegisterEffect(e4,tp) 
		end 
	end
end
function c21362821.sumlimit(e,c)
	return c:IsCode(e:GetLabel())
end
function c21362821.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel()) and re:IsActiveType(TYPE_MONSTER)
end
function c21362821.plfil(c)
	return c:IsCode(59197169) and not c:IsForbidden() 
end 
function c21362821.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21362821.plfil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end 
end
function c21362821.pcfilter(c)
	return c:IsCode(21362800) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function c21362821.plop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	local tc=Duel.SelectMatchingCard(tp,c21362821.plfil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst() 
	if tc then 
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		if Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true) and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and Duel.IsExistingMatchingCard(c21362821.pcfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(21362821,1)) then 
			local pc=Duel.SelectMatchingCard(tp,c21362821.pcfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil):GetFirst()
			Duel.MoveToField(pc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) 
		end
	end 
end 



