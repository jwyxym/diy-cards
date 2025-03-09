--泰拉饭 富营养海嗣全餐
function c31280213.initial_effect(c)
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
	e1:SetCountLimit(1,31280213)
	c:RegisterEffect(e1)
	--atk 
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION) 
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,11280213)  
	e2:SetTarget(c31280213.xxtg)
	e2:SetOperation(c31280213.xxop)
	c:RegisterEffect(e2)
end
c31280213.SetCard_TnT_TLmeal=true 
function c31280213.xtgfil(c) 
	return c:IsFaceup() and (c:IsAttribute(ATTRIBUTE_WATER) or c:IsSetCard(0x3a21)) 
end 
function c31280213.xxtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(c31280213.xtgfil,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsAbleToDeck() end 
	Duel.SelectTarget(tp,c31280213.xtgfil,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)  
end
function c31280213.xxop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	if not (c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,2,REASON_EFFECT)~=0) then return end 
	local tc=Duel.GetFirstTarget() 
	if tc:IsRelateToEffect(e) then   
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(31280213,1))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_DISABLE)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2,true)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_DISEFFECT)
		e3:SetRange(LOCATION_MZONE)
		e3:SetValue(function(e,ct)
		local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
		return te:GetHandler()==e:GetHandler() end)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3,true)
	end 
end 
