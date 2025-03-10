--莱欧斯小队-派对！
function c31280205.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--search
	local e3=Effect.CreateEffect(c) 
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY) 
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,31280205)  
	e3:SetTarget(c31280205.actg)
	e3:SetOperation(c31280205.acop)
	c:RegisterEffect(e3)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_TODECK) 
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET) 
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,11280205) 
	e1:SetTarget(c31280205.cltg)
	e1:SetOperation(c31280205.clop)
	c:RegisterEffect(e1)
end
c31280205.SetCard_TnT_Lwsteam=true 
function c31280205.acfilter(c,tp)
	return c:IsSetCard(0xca1) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS) and c:GetActivateEffect():IsActivatable(tp) and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_SZONE,0,1,nil,c:GetCode())
end
function c31280205.actg(e,tp,eg,ep,ev,re,r,rp,chk)  
	if chk==0 then return Duel.IsExistingMatchingCard(c31280205.acfilter,tp,LOCATION_DECK,0,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end 
end
function c31280205.acop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	if Duel.IsExistingMatchingCard(c31280205.acfilter,tp,LOCATION_DECK,0,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then  
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		local tc=Duel.SelectMatchingCard(tp,c31280205.acfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst() 
		if tc then 
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			local te=tc:GetActivateEffect()
			local tep=tc:GetControler()
			local cost=te:GetCost()
			local op=te:GetOperation()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end 
			if op then op(te,tep,eg,ep,ev,re,r,rp) end 
			Duel.RaiseEvent(tc,EVENT_CHAINING,te,r,rp,ep,ev)
		end 
	end 
end
function c31280205.tdfil(c) 
	return c:IsFaceup() and c:IsAbleToDeck() and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(0xca1)  
end 
function c31280205.cltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) and Duel.IsExistingMatchingCard(c31280205.tdfil,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_SZONE)
end
function c31280205.clop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local sc=Duel.SelectMatchingCard(tp,c31280205.tdfil,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
	local tc=Duel.GetFirstTarget()
	if sc and Duel.SendtoDeck(sc,nil,2,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end

