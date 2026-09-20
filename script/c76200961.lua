--影之仆 海德琳
function c76200961.initial_effect(c)
	aux.AddCodeList(c,76200681)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,c76200961.mfilter,2,true)
	--pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(DOUBLE_DAMAGE)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,76200961)
	e2:SetCondition(c76200961.drcon)
	e2:SetTarget(c76200961.drtg)
	e2:SetOperation(c76200961.drop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TOGRAVE+CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,76200961+1)
	e3:SetCondition(c76200961.thcon)
	e3:SetTarget(c76200961.thtg)
	e3:SetOperation(c76200961.thop)
	c:RegisterEffect(e3)
end
function c76200961.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function c76200961.filter(c)
	return (c:IsCode(76200681) or aux.IsCodeListed(c,76200681)) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function c76200961.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
	local b2=Duel.IsExistingMatchingCard(c76200961.filter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return c:IsAbleToRemove() and (b1 or b2) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end
function c76200961.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	if c:IsRelateToChain() and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		if c:GetOriginalCode()==76200961 then
			c:RegisterFlagEffect(76200961,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(76200961,2))
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabel(fid)
			e1:SetLabelObject(c)
			e1:SetCountLimit(1)
			e1:SetCondition(c76200961.retcon)
			e1:SetOperation(c76200961.retop)
			Duel.RegisterEffect(e1,tp)
		end
		local b1=Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		local b2=Duel.IsExistingMatchingCard(c76200961.filter,tp,LOCATION_DECK,0,1,nil)
		local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(76200961,0)},{b2,aux.Stringid(76200961,1)})
		if op==1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
			local g=Duel.SelectMatchingCard(tp,aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
			local tc=g:GetFirst()
			if tc then
				Duel.HintSelection(g)
				Duel.NegateRelatedChain(tc,RESET_TURN_SET)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e2)
			end
		elseif op==2 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
			local g=Duel.SelectMatchingCard(tp,c76200961.filter,tp,LOCATION_DECK,0,1,1,nil)
			if g:GetCount()<=0 then return end
			local tc=g:GetFirst()
			if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tc)
			else
				Duel.SendtoGrave(tc,REASON_EFFECT)
			end
		end
	end
end
function c76200961.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(76200961)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
function c76200961.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
function c76200961.drcon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return loc==LOCATION_HAND and re:IsActiveType(TYPE_MONSTER)
end
function c76200961.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c76200961.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function c76200961.mfilter(c)
	return (aux.IsCodeListed(c,76200681) and c:IsType(TYPE_MONSTER))
		or (c:IsType(TYPE_PENDULUM) and (c:IsAttack(1200) or c:IsDefense(1200)))
end
