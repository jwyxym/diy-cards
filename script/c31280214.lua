--泰拉饭 无人机下午茶
function c31280214.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--change cost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(31280208)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,31280214)
	c:RegisterEffect(e1)
	--atk 
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION) 
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,11280214)  
	e2:SetTarget(c31280214.xxtg)
	e2:SetOperation(c31280214.xxop)
	c:RegisterEffect(e2)
end
c31280214.SetCard_TnT_TLmeal=true 
function c31280214.xtgfil(c) 
	return c:IsFaceup() and (c:IsAttribute(ATTRIBUTE_FIRE) or c:IsSetCard(0x3a21)) 
end 
function c31280214.xxtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(c31280214.xtgfil,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsAbleToDeck() end 
	Duel.SelectTarget(tp,c31280214.xtgfil,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)  
end
function c31280214.xxop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	if not (c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,2,REASON_EFFECT)~=0) then return end 
	local tc=Duel.GetFirstTarget() 
	if tc:IsRelateToEffect(e) then   
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCountLimit(1)
		e1:SetValue(function(e,re,r,rp)
		return bit.band(r,REASON_EFFECT)~=0 end)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(31280214,1))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetValue(tc:GetBaseDefense())
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2) 
	end 
end 
