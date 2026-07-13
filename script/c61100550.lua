--山樱剑技-幻影破魔矢
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,61100536)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
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
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and ep==1-tp and Duel.IsChainDisablable(ev)
end
function s.filter1(c,tp)
	return c:IsType(TYPE_TRAP) and c:IsSetCard(0x57b) and not c:IsCode(id) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end
function s.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x57b)
end
function s.filter3(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.ffilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x57b) and c:IsDestructable(e) and Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
function s.spfilter(c,fc)
	return fc>c:GetAttack() and c:IsAbleToRemove()
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)) then return end
	local g=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,0,nil)
	local b1=Duel.IsExistingMatchingCard(s.filter3,tp,0,LOCATION_ONFIELD,1,c)
	local b2=Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	local b3=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil,tp)
	if #g>0 and (b1 or b2 or b3) then
		local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)},{b3,aux.Stringid(id,2)},{true,aux.Stringid(id,3)})
		if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil)
		Duel.Destroy(dg,REASON_EFFECT)
		local sg=Duel.GetMatchingGroup(s.filter3,tp,0,LOCATION_ONFIELD,aux.ExceptThisCard(e))
		Duel.Destroy(sg,REASON_EFFECT)
		elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		local fc=dg:GetFirst():GetAttack()
		Duel.Destroy(dg,REASON_EFFECT)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local oppg=Duel.SelectMatchingCard(tp,s.spfilter,tp,0,LOCATION_MZONE,1,1,nil,fc)
		if #oppg>0 then
			Duel.HintSelection(oppg)
			Duel.Remove(oppg,POS_FACEDOWN,REASON_EFFECT)
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
	return c:IsFaceup() and c:IsCode(61100536)
end
function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end