--悖论特遣队“摆渡人”
function c37711000.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c37711000.spcon)
	e1:SetCost(c37711000.spcost)
	e1:SetTarget(c37711000.sptg)
	e1:SetOperation(c37711000.spop)
	c:RegisterEffect(e1)
	--remove
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37711000,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_F)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c37711000.rmcon)
	e2:SetCost(c37711000.rmcost)
	e2:SetTarget(c37711000.rmtg)
	e2:SetOperation(c37711000.rmop)
	c:RegisterEffect(e2)
end
function c37711000.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp or Duel.IsBattlePhase()--Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
function c37711000.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c37711000.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c37711000.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(37711000,2)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local rg=g:Select(tp,1,3,nil)
	Duel.HintSelection(rg)
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end
function c37711000.rmcon(e,tp,eg,ep,ev,re,r,rp)
	if ev<2 then return false end
	return rp==Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_PLAYER)
end
function c37711000.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	if Duel.Remove(c,0,REASON_COST+REASON_TEMPORARY)~=0 then
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_CHAIN_END)
		e0:SetReset(RESET_PHASE+PHASE_END)
		e0:SetLabelObject(c)
		e0:SetCountLimit(1)
		e0:SetOperation(c37711000.retop)
		Duel.RegisterEffect(e0,tp)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(37711000,1))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(44401001)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CHAIN)
		c:RegisterEffect(e1)
	end
end
function c37711000.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
function c37711000.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_DECK+LOCATION_GRAVE)
end
function c37711000.rmfilter(c)
	return c:IsSetCard(0x2a9) and c:IsAbleToRemove() and aux.NecroValleyFilter()(c)
end
function c37711000.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c37711000.rmfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
