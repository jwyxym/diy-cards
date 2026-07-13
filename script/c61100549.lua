--山樱剑技-终焉樱
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,61100533)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
	
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsControler,tp,0,LOCATION_MZONE,1,nil,1-tp) end
	Duel.SelectTarget(tp,Card.IsControler,tp,0,LOCATION_MZONE,1,1,nil,1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end
function s.filter1(c,tp)
	return c:IsType(TYPE_TRAP) and c:IsSetCard(0x57b) and not c:IsCode(id) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end
function s.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x57b)
end
function s.ffilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsFaceup() and c:IsSetCard(0x57b) and c:IsDestructable(e) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,c)
end
function s.spfilter(c,fc)
	return aux.IsMaterialListCode(fc,c:GetCode()) and c:IsAbleToHand()
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0) then return end
	local g=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,0,nil)
	local b1=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	local b3=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil,tp)
	if #g>0 and (b1 or b2 or b3) then
		local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)},{b3,aux.Stringid(id,2)},{true,aux.Stringid(id,3)})
		if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil)
		Duel.Destroy(dg,REASON_EFFECT)
		local oppg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		if #oppg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local tg=oppg:Select(tp,1,1,nil)
			Duel.Destroy(tg,REASON_EFFECT)
			end
		elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		local fc=dg:GetFirst()
		if Duel.Destroy(fc,REASON_EFFECT)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local oppg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,fc)
			if #oppg>0 then
			Duel.SendtoHand(oppg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,oppg)
			end
		end
		elseif op==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil)
		local sdg=Duel.Destroy(dg,REASON_EFFECT)
		local oppg=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_DECK,0,nil)
		if #oppg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local dc=oppg:Select(tp,1,1,nil):GetFirst()
			Duel.SSet(tp,dc,REASON_EFFECT)
			if dc:IsType(TYPE_TRAP) and sdg>0 and aux.IsCodeListed(dc,dg:GetFirst():GetCode()) then
				local e1a=Effect.CreateEffect(c)
				e1a:SetDescription(aux.Stringid(id,4))
				e1a:SetType(EFFECT_TYPE_SINGLE)
				e1a:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e1a:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e1a:SetReset(RESET_EVENT+RESETS_STANDARD)
				dc:RegisterEffect(e1a)
				end
			end
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetValue(s.actlimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.actlimit(e,re,tp)
	return re:GetHandler():IsCode(id)
end
function s.filter(c)
	return c:IsFaceup() and c:IsCode(61100533)
end
function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end