--莱欧斯小队 森西
function c31280201.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,31280201) 
	e1:SetTarget(c31280201.sptg)
	e1:SetOperation(c31280201.spop)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(function(e,c) 
	return c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_SPELL) and c:IsSetCard(0xca1) end)
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c) 
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY) 
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,11280201) 
	e3:SetCondition(c31280201.accon)
	e3:SetTarget(c31280201.actg)
	e3:SetOperation(c31280201.acop)
	c:RegisterEffect(e3)
end
--c31280201.SetCard_TnT_Lwsteam=true 
function c31280201.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c31280201.desfil(c) 
	return c:IsFaceup() or c:IsLocation(LOCATION_HAND) 
end 
function c31280201.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(c31280201.desfil,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(31280201,0)) then 
		Duel.BreakEffect()
		local dg=Duel.SelectMatchingCard(tp,c31280201.desfil,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil) 
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
function c31280201.dackfil(c) 
	return c:IsReason(REASON_EFFECT+REASON_BATTLE) and c:IsType(TYPE_MONSTER)  
end 
function c31280201.accon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31280201.dackfil,1,nil)
end
function c31280201.ackfil(c) 
	return c:IsSetCard(0xca1) and c:IsFaceup()  
end 
function c31280201.acfilter(c,tp)
	return c:IsSetCard(0xca1) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS) and c:GetActivateEffect():IsActivatable(tp) and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_SZONE,0,1,nil,c:GetCode())
end
function c31280201.actg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local b1=Duel.IsExistingMatchingCard(c31280201.acfilter,tp,LOCATION_DECK,0,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
	local b2=Duel.IsExistingMatchingCard(c31280201.ackfil,tp,LOCATION_SZONE,0,1,nil)
	if chk==0 then return b1 or b2 end 
	if b2 then 
		e:SetCategory(CATEGORY_RECOVER)
		Duel.SetTargetPlayer(tp) 
		Duel.SetTargetParam(1100)
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1100) 
	else 
		e:SetCategory(0)
	end 
end
function c31280201.acop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(c31280201.acfilter,tp,LOCATION_DECK,0,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
	local b2=Duel.IsExistingMatchingCard(c31280201.ackfil,tp,LOCATION_SZONE,0,1,nil)
	if b2 then 
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Recover(p,d,REASON_EFFECT) 
	else 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		local tc=Duel.SelectMatchingCard(tp,c31280201.acfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst() 
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








