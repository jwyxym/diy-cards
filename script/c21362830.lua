--魔诞 斩刃将 奥尔盖特
function c21362830.initial_effect(c)
	aux.AddCodeList(c,21362800) 
	c:EnableReviveLimit()
	--tohand
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,21362830)
	e1:SetCost(c21362830.thcost)
	e1:SetTarget(c21362830.thtg)
	e1:SetOperation(c21362830.thop)
	c:RegisterEffect(e1) 
	--to deck 
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,21362830)
	e2:SetCondition(c21362830.tdcon) 
	e2:SetCost(c21362830.tdcost)
	e2:SetTarget(c21362830.tdtg)
	e2:SetOperation(c21362830.tdop)
	c:RegisterEffect(e2) 
	--xx
	--local e2=Effect.CreateEffect(c) 
	--e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_ATKCHANGE) 
	--e2:SetType(EFFECT_TYPE_QUICK_O) 
	--e2:SetCode(EVENT_FREE_CHAIN)  
	--e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	--e2:SetRange(LOCATION_MZONE) 
	--e2:SetCountLimit(1,21362831) 
	--e2:SetTarget(c21362830.xxtg) 
	--e2:SetOperation(c21362830.xxop) 
	--c:RegisterEffect(e2) 
end
function c21362830.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function c21362830.thfilter(c)
	return (c:IsCode(21362800) or aux.IsCodeListed(c,21362800)) and (c:IsAbleToGrave() or c:IsAbleToRemove())
end
function c21362830.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21362830.thfilter,tp,LOCATION_DECK,0,1,nil) end 
end
function c21362830.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c21362830.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		if tc and tc:IsAbleToGrave() and (not tc:IsAbleToRemove() or Duel.SelectOption(tp,1191,1192)==0) then
			Duel.SendtoGrave(tc,REASON_EFFECT)
		else
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function c21362830.tckfil(c) 
	return c:IsFaceup() and c:IsRace(RACE_FIEND) and c:IsSummonLocation(LOCATION_EXTRA)   
end 
function c21362830.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c21362830.tckfil,tp,LOCATION_MZONE,0,1,nil)   
end 
function c21362830.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_COST)
end
function c21362830.thfilter(c)
	return (c:IsCode(21362800) or aux.IsCodeListed(c,21362800)) and (c:IsAbleToGrave() or c:IsAbleToRemove())
end
function c21362830.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end 
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)  
end
function c21362830.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil):GetFirst() 
	if tc then 
		if tc:IsSetCard(0xba38) then 
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT) 
			if Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(21362830,1)) then  
				Duel.BreakEffect()
				Duel.Draw(tp,1,REASON_EFFECT)
			end 
		else 
			Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
		end 
	end 
end 



function c21362830.xxfil(c) 
	if c:IsLocation(LOCATION_GRAVE) then 
		return c:IsAbleToRemove()
	elseif c:IsLocation(LOCATION_REMOVED) then 
		return c:IsAbleToGrave()
	else 
		return false 
	end  
end 
function c21362830.xxtg(e,tp,eg,ep,ev,re,r,rp,chk) 
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c21362830.xxfil(chkc) end 
	if chk==0 then return Duel.IsExistingTarget(c21362830.xxfil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end  
	local tc=Duel.SelectTarget(tp,c21362830.xxfil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil):GetFirst() 
	if tc:IsLocation(LOCATION_GRAVE) then 
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0) 
	end 
end
function c21362830.xxop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local tc=Duel.GetFirstTarget() 
	if tc:IsRelateToEffect(e) then  
		if tc:IsLocation(LOCATION_GRAVE) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsRace(RACE_FIEND) and tc:IsAbleToHand() and Duel.SelectYesNo(tp,aux.Stringid(21362830,0)) then 
			Duel.BreakEffect()
			Duel.SendtoHand(tc,nil,REASON_EFFECT) 
		end 
		if tc:IsLocation(LOCATION_REMOVED) and Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)~=0 and tc:IsRace(RACE_FIEND) then 
			local e1=Effect.CreateEffect(c) 
			e1:SetType(EFFECT_TYPE_FIELD) 
			e1:SetCode(EFFECT_UPDATE_ATTACK) 
			e1:SetTargetRange(LOCATION_ONFIELD,0) 
			e1:SetTarget(function(e,c) 
			return c:IsSetCard(0xba38) end) 
			e1:SetValue(1000) 
			e1:SetReset(RESET_PHASE+PHASE_END) 
			Duel.RegisterEffect(e1,tp)
		end  
	end 
end 





