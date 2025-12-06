--圣教对异端的讨伐
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--position change
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
function s.actfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x728) and c:IsType(TYPE_RITUAL)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	local g=Duel.SelectMatchingCard(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		Duel.AdjustInstantly()
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_FIELD)
			e3:SetCode(EFFECT_DISABLE)
			e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e3:SetTarget(s.distg)
			e3:SetLabelObject(tc)
			e3:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e3,tp)
			local e4=Effect.CreateEffect(e:GetHandler())
			e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e4:SetCode(EVENT_CHAIN_SOLVING)
			e4:SetCondition(s.discon)
			e4:SetOperation(s.disop)
			e4:SetLabelObject(tc)
			e4:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e4,tp)
			local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
			if #sg>0 and Duel.GetTurnPlayer()==tp
				and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
				and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.BreakEffect()
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
end
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.distg(e,c)
	local tc=e:GetLabelObject()
	return c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function s.posfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x728) and c:IsCanTurnSet()
		and Duel.IsExistingTarget(s.posfilter2,0,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
function s.posfilter2(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.posfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g1=Duel.SelectTarget(tp,s.posfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g2=Duel.SelectTarget(tp,s.posfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,g1:GetFirst())
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,2,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
