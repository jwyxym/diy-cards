--墨染乐章 质问
function c21301042.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x682),4,2)
	--aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x682),4,2,c21301042.ovfilter,aux.Stringid(21301042,0),2,c21301042.xyzop)
	c:EnableReviveLimit()
	--to hand 
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,21301042)
	e1:SetTarget(c21301042.thtg)
	e1:SetOperation(c21301042.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2)  
	c21301042.remove_effect=e2  
	--indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3) 
	--apply effect
	local e4=Effect.CreateEffect(c)  
	e4:SetType(EFFECT_TYPE_IGNITION) 
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,21301043)  
	e4:SetCost(c21301042.effcost)
	e4:SetTarget(c21301042.efftg)
	e4:SetOperation(c21301042.effop)
	c:RegisterEffect(e4)
end
function c21301042.mfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function c21301042.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x682) and not c:IsType(TYPE_XYZ)
end
function c21301042.xrmfil(c) 
	return c:IsAbleToRemoveAsCost() and c:IsSetCard(0x682)  
end 
function c21301042.xyzop(e,tp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21301042.xrmfil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) and Duel.GetFlagEffect(tp,21301042)==0 end
	Duel.RegisterFlagEffect(tp,21301042,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1) 
	local g=Duel.SelectMatchingCard(tp,c21301042.xrmfil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil) 
	Duel.Remove(g,POS_FACEUP,REASON_COST) 
end
function c21301042.thfilter(c)
	if not (c:IsSetCard(0x682)) then return false end
	return c:IsAbleToHand() 
end
function c21301042.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21301042.thfilter,tp,LOCATION_DECK,0,1,nil) end 
end
function c21301042.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,c21301042.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then 
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc) 
	end
end
function c21301042.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c21301042.efffilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not (c:IsSetCard(0x682) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()) then return false end
	local te=c.remove_effect
	if not te then return false end
	local tg=te:GetTarget()
	return not tg or tg and tg(e,tp,eg,ep,ev,re,r,rp,0)
end
function c21301042.efftg(e,tp,eg,ep,ev,re,r,rp,chk) 
	if chk==0 then return Duel.IsExistingMatchingCard(c21301042.efffilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,c21301042.efffilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp):GetFirst()  
	Duel.ClearTargetCard()
	tc:CreateEffectRelation(e)
	e:SetLabelObject(tc)
	Duel.SendtoGrave(tc,REASON_EFFECT)
	local te=tc.remove_effect
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
end
function c21301042.effop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	local tc=e:GetLabelObject() 
	local te=tc.remove_effect
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end  
end


