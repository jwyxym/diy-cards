--墨染乐章 迷惑
function c21301018.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN) 
	e1:SetCountLimit(1,21301018+EFFECT_COUNT_CODE_OATH)  
	e1:SetCondition(c21301018.condition)
	e1:SetTarget(c21301018.target)
	e1:SetOperation(c21301018.activate)
	c:RegisterEffect(e1)
	--rme
	local e2=Effect.CreateEffect(c)  
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,21301019)
	e2:SetTarget(c21301018.rmetg)
	e2:SetOperation(c21301018.rmeop)
	c:RegisterEffect(e2)
	c21301018.remove_effect=e2  
end
function c21301018.ckfil(c) 
	return c:IsFaceup() and c:IsSetCard(0x682)   
end 
function c21301018.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c21301018.ckfil,tp,LOCATION_MZONE,0,1,nil)  
end 
function c21301018.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function c21301018.cthfil(c) 
	return c:IsSetCard(0x682) and c:IsAbleToHand()  
end 
function c21301018.activate(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp)
		if Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsSetCard(0x682) and c:IsType(TYPE_XYZ) end,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(c21301018.cthfil,tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(21301018,0)) then 
			Duel.BreakEffect()
			local sg=Duel.SelectMatchingCard(tp,c21301018.cthfil,tp,LOCATION_GRAVE,0,1,1,nil) 
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end 
	end
end 
function c21301018.rmetg(e,tp,eg,ep,ev,re,r,rp,chk)  
	if chk==0 then return true end 
end
function c21301018.rmeop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	--control
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE) 
	e1:SetCode(EFFECT_CANNOT_CHANGE_CONTROL) 
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) 
	return c:IsSetCard(0x682) end)
	e1:SetReset(RESET_PHASE+PHASE_END,2) 
	Duel.RegisterEffect(e1,tp)
end 


