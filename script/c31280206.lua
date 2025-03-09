--莱欧斯小队-生鲜捕获
function c31280206.initial_effect(c)
	--Activate 
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE) 
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,31280206) 
	e1:SetCondition(c31280206.accon)
	e1:SetTarget(c31280206.actg)
	e1:SetOperation(c31280206.acop)
	c:RegisterEffect(e1)
	--equip
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET) 
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,11280206) 
	e2:SetCondition(c31280206.eqcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c31280206.eqtg)
	e2:SetOperation(c31280206.eqop)
	c:RegisterEffect(e2)
end
c31280206.SetCard_TnT_Lwsteam=true 
function c31280206.accon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(function(c) return c:IsSetCard(0x3a21) and c:IsFaceup() end,tp,LOCATION_MZONE,0,1,nil)
end 
function c31280206.actg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c31280206.acop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function c31280206.ackfil(c) 
	return c:IsSetCard(0x3a22) and c:IsFaceup()  
end 
function c31280206.eqcon(e,tp,eg,ep,ev,re,r,rp) 
	return Duel.IsExistingMatchingCard(c31280206.ackfil,tp,LOCATION_SZONE,0,1,nil) and aux.exccon(e,tp,eg,ep,ev,re,r,rp) 
end 
function c31280206.eqfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function c31280206.tgfilter(c)
	return c:IsFaceup()
end
function c31280206.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(c31280206.eqfilter,tp,0,LOCATION_GRAVE,1,nil)
		and Duel.IsExistingTarget(c31280206.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g2=Duel.SelectTarget(tp,c31280206.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g1=Duel.SelectTarget(tp,c31280206.eqfilter,tp,0,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g1,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g1,1,0,0)
end
function c31280206.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc1=g:Filter(Card.IsControler,nil,1-tp):GetFirst()
	local tc2=g:Filter(Card.IsControler,nil,tp):GetFirst()
	if tc1 and tc2 and tc2:IsFaceup() then
		local atk=tc1:GetAttack()
		if not Duel.Equip(tp,tc1,tc2,false) then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(tc2)
		e1:SetValue(function (e,c)
		return c==e:GetLabelObject() end)
		tc1:RegisterEffect(e1) 
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(1000)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e2)
	end
end 

