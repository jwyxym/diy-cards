--落幕，落墨
function c21301030.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN) 
	e1:SetCountLimit(1,21301030+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c21301030.activate)
	c:RegisterEffect(e1)  
	--immune 
	local e2=Effect.CreateEffect(c) 
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(function(e,te) 
	return te:IsActiveType(TYPE_MONSTER) and e:GetOwnerPlayer()~=te:GetOwnerPlayer() and e:GetHandler():GetColumnGroup():IsContains(te:GetOwner()) end)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(function(e,c) 
	return c:IsSetCard(0x682) end)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)  
	--set
	local e3=Effect.CreateEffect(c)  
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END) 
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,21301031)
	e3:SetCondition(function(e) 
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
	e3:SetTarget(c21301030.settg)
	e3:SetOperation(c21301030.setop)
	c:RegisterEffect(e3)
end
function c21301030.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x682) and (c:IsAbleToHand() or c:IsAbleToRemove())
end
function c21301030.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c21301030.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(21301030,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if tc:IsAbleToHand() and (not tc:IsAbleToRemove() or Duel.SelectOption(tp,1190,1192)==0) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function c21301030.setfilter(c)
	return c:IsSetCard(0x682) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function c21301030.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21301030.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
end
function c21301030.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,c21301030.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end

