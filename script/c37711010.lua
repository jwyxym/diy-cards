--悖论特遣队“马格南”
function c37711010.initial_effect(c)
	--set
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c37711010.setcon)
	e1:SetTarget(c37711010.settg)
	e1:SetOperation(c37711010.setop)
	c:RegisterEffect(e1)
	--remove
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37711010,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_F)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c37711010.rmcon)
	e2:SetCost(c37711010.rmcost)
	e2:SetTarget(c37711010.rmtg)
	e2:SetOperation(c37711010.rmop)
	c:RegisterEffect(e2)
	--sign
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SUMMON_SUCCESS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetOperation(c37711010.regop)
	c:RegisterEffect(e0)
end
function c37711010.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp or Duel.IsBattlePhase()--Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
function c37711010.setfilter(c)
	return c:IsSetCard(0x2a9) and c:IsFaceupEx() and c:IsSSetable()
end
function c37711010.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local loc=c:IsSummonType(SUMMON_TYPE_NORMAL) and c:GetFlagEffect(37711010)==0 and LOCATION_DECK+LOCATION_REMOVED or LOCATION_REMOVED
	if chk==0 then return Duel.IsExistingMatchingCard(c37711010.setfilter,tp,loc,0,1,nil) end
	c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(37711010,4))
end
function c37711010.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local loc=c:IsRelateToChain() and c:IsSummonType(SUMMON_TYPE_NORMAL) and c:GetFlagEffect(37711010)==0 and LOCATION_DECK+LOCATION_REMOVED or LOCATION_REMOVED
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local sc=Duel.SelectMatchingCard(tp,c37711010.setfilter,tp,loc,0,1,1,nil):GetFirst()
	if not sc then return end
	if sc:IsLocation(LOCATION_DECK) then
		c:RegisterFlagEffect(37711010,RESET_EVENT+RESETS_WITHOUT_TEMP_REMOVE+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(37711010,5))
	end
	Duel.SSet(tp,sc)
end
function c37711010.rmcon(e,tp,eg,ep,ev,re,r,rp)
	if ev<2 then return false end
	return rp==Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_PLAYER)
end
function c37711010.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	if Duel.Remove(c,0,REASON_COST+REASON_TEMPORARY)~=0 then
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_CHAIN_END)
		e0:SetReset(RESET_PHASE+PHASE_END)
		e0:SetLabelObject(c)
		e0:SetCountLimit(1)
		e0:SetOperation(c37711010.retop)
		Duel.RegisterEffect(e0,tp)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(37711010,1))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(44401001)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CHAIN)
		c:RegisterEffect(e1)
	end
end
function c37711010.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
function c37711010.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_DECK+LOCATION_GRAVE)
end
function c37711010.rmfilter(c)
	return c:IsSetCard(0x2a9) and c:IsAbleToRemove() and aux.NecroValleyFilter()(c)
end
function c37711010.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c37711010.rmfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
function c37711010.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsSummonType(SUMMON_TYPE_NORMAL) then return end
	c:RegisterFlagEffect(0,RESET_EVENT+RESETS_WITHOUT_TEMP_REMOVE-RESET_TURN_SET,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(37711010,2))
end
