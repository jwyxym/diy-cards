--墨染乐章 寻觅
function c21301027.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,21301027+EFFECT_COUNT_CODE_OATH) 
	e1:SetTarget(c21301027.target)
	e1:SetOperation(c21301027.activate)
	c:RegisterEffect(e1)  
	--sre
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION) 
	e2:SetRange(LOCATION_GRAVE) 
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,21301028) 
	e2:SetTarget(c21301027.sretg)
	e2:SetOperation(c21301027.sreop)
	c:RegisterEffect(e2) 
end
function c21301027.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c21301027.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c21301027.filter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(c21301027.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,c21301027.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c21301027.activate(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsSetCard(0x682) and c:IsType(TYPE_XYZ) end,tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(21301027,0)) then   
			Duel.BreakEffect() 
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
			e1:SetTarget(c21301027.distg)
			e1:SetLabelObject(tc)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_CHAIN_SOLVING)
			e2:SetCondition(c21301027.discon)
			e2:SetOperation(c21301027.disop)
			e2:SetLabelObject(tc)
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2,tp)
		end 
	end
end
function c21301027.distg(e,c)
	local tc=e:GetLabelObject()
	return c:IsCode(tc:GetCode()) 
end
function c21301027.discon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return re:GetHandler():IsCode(tc:GetCode())
end
function c21301027.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function c21301027.srefil(c,e,tp) 
	local b1=c:IsAbleToHand() and e:GetHandler():IsAbleToRemove()
	local b2=e:GetHandler():IsAbleToHand() and c:IsAbleToRemove()
	return c:IsSetCard(0x682) and (b1 or b2)
end 
function c21301027.sretg(e,tp,eg,ep,ev,re,r,rp,chk)  
	if chk==0 then return Duel.IsExistingMatchingCard(c21301027.srefil,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end 
	local tc=Duel.SelectTarget(tp,c21301027.srefil,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp):GetFirst()   
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE) 
end
function c21301027.sreop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) then return end 
	if not tc:IsRelateToEffect(e) then return end 
	local g=Group.CreateGroup()
	local b1=tc:IsAbleToHand() and e:GetHandler():IsAbleToRemove()
	local b2=e:GetHandler():IsAbleToHand() and tc:IsAbleToRemove()
	if b1 then g:AddCard(tc) end 
	if b2 then g:AddCard(c) end   
	local sc=g:Select(tp,1,1,nil):GetFirst() 
	local rc=g:Filter(aux.TRUE,sc):GetFirst()
	if sc and Duel.SendtoHand(sc,nil,REASON_EFFECT)~=0 and rc then  
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
	end
end
