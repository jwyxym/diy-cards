--黏糊糊的大?爆?发!
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(TIMING_MAIN_END+TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+10000)
	e2:SetCondition(s.e2con)
	e2:SetCost(aux.bfgcost)   
	e2:SetTarget(s.e2tg)   
	e2:SetOperation(s.e2op)
	c:RegisterEffect(e2)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCondition(s.accon)
	e4:SetCost(s.accost)
	c:RegisterEffect(e4)
	
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE,0)
	local g2=Duel.GetOverlayGroup(tp,1,0)
	g:Merge(g2)
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local ng=g:Filter(Card.IsRace,nil,RACE_AQUA):Select(tp,2,2,nil)
	Duel.SendtoDeck(ng,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsControler(1-tp) and Duel.IsChainDisablable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetCountLimit(1)
	e1:SetOperation(s.op)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x1579,1)
	if #g>0 then
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1579,1)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetCondition(s.lvcon)
			e1:SetValue(3)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CHANGE_RACE)
			e2:SetValue(RACE_AQUA)
			tc:RegisterEffect(e2)
			local e3=e1:Clone()
			e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e3:SetValue(ATTRIBUTE_WATER)
			tc:RegisterEffect(e3)
		tc=g:GetNext()
		end
	end
end
function s.lvcon(e)
	return e:GetHandler():GetCounter(0x1579)>0 and e:GetHandler():GetLevel()>0
end
function s.e2con(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetTurnPlayer()~=tp and not Duel.IsMainPhase())
		or (Duel.GetTurnPlayer()==tp and Duel.IsMainPhase())
end

function s.xyzfilter(c)
	return c:IsControler(tp) and c:IsRace(RACE_AQUA) and c:IsType(TYPE_XYZ)
end
function s.xyzfilter2(c)
	return c:GetCounter(0x1579)>0
end

function s.e2tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.xyzfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(s.xyzfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.e2op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	local g=Duel.GetMatchingGroup(function(c)
		return c~=tc and c:GetCounter(0x1579)>0 and c:IsCanBeXyzMaterial(tc) and not c:IsImmuneToEffect(e)
	end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 then
		for ac in aux.Next(g) do
			local og=ac:GetOverlayGroup()
			if #og>0 then
				Duel.Overlay(tc,og)
			end
		end
		Duel.Overlay(tc,g)
	end
end
function s.accon(e)
	return e:GetHandler():IsStatus(STATUS_SET_TURN) and e:GetHandler():IsLocation(LOCATION_ONFIELD)
end
function s.cfilter(c)
	return c:IsFacedown() and c:IsSetCard(0x579)
end
function s.accost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,5,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,5,5,e:GetHandler())
	Duel.ConfirmCards(1-tp,g)
end