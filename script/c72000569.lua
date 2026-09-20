--流星幻象
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,44508094)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--to deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--cannot be target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.efftg)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--to deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
function s.cfilter(c,tp)
	return c:IsType(TYPE_TUNER) and c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,e:GetHandler(),tp)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
	end
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD) then
		Duel.HintSelection(g)
	end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.sumcon)
	e1:SetOperation(s.sumsuc)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_END)
	e2:SetOperation(s.limop2)
	Duel.RegisterEffect(e2,tp)
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
function s.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentChain()==0 then
		Duel.SetChainLimitTillChainEnd(s.efun)
	elseif Duel.GetCurrentChain()==1 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil)
end
function s.efun(e,ep,tp)
	return ep==tp
end
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 then
		Duel.SetChainLimitTillChainEnd(s.efun)
	end
	Duel.ResetFlagEffect(tp,id)
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ResetFlagEffect(tp,id)
	e:Reset()
end
function s.efftg(e,c)
	return c:IsType(TYPE_SYNCHRO)
end
function s.tdfilter(c,e)
	return c:IsSetCard(0x1017) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and (not e or c:IsCanBeEffectTarget(e))
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=5 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tg=g:SelectSubGroup(tp,aux.dncheck,false,1,5)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,tg:GetCount(),0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()==0 then return end
	if Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)==0 then return end
	local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	if ct>0 then Duel.SortDecktop(tp,tp,ct) end
end
