--泰拉饭 墨魉果酱果酒果汁大拼盘
function c31280212.initial_effect(c)
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
	e1:SetCountLimit(1,31280212)
	c:RegisterEffect(e1)
	--atk 
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION) 
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,11280212)  
	e2:SetTarget(c31280212.xxtg)
	e2:SetOperation(c31280212.xxop)
	c:RegisterEffect(e2)
end
c31280212.SetCard_TnT_TLmeal=true 
function c31280212.xtgfil(c) 
	return c:IsFaceup() and (c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_WIND) or c:IsSetCard(0x3a21)) 
end 
function c31280212.xxtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(c31280212.xtgfil,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsAbleToDeck() end 
	Duel.SelectTarget(tp,c31280212.xtgfil,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)  
end
function c31280212.xxop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	if not (c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,2,REASON_EFFECT)~=0) then return end 
	local tc=Duel.GetFirstTarget() 
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then   
		local e1=Effect.CreateEffect(tc)
		e1:SetDescription(aux.Stringid(31280212,1)) 
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O) 
		e1:SetCode(EVENT_BATTLE_DESTROYING) 
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)   
		e1:SetCountLimit(3)
		e1:SetCondition(c31280212.atcon)
		e1:SetOperation(c31280212.atop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
		if not tc:IsType(TYPE_EFFECT) then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_ADD_TYPE)
			e2:SetValue(TYPE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
		end
	end 
end 
function c31280212.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetAttacker()==c and aux.bdocon(e,tp,eg,ep,ev,re,r,rp) 
end 
function c31280212.atop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	if c:IsRelateToEffect(e) and c:IsFaceup() then 
		local e1=Effect.CreateEffect(c) 
		e1:SetType(EFFECT_TYPE_SINGLE) 
		e1:SetCode(EFFECT_UPDATE_ATTACK)  
		e1:SetValue(-800) 
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		Duel.ChainAttack()
	end 
end

