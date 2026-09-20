--绝对的影之仆
local s,id,o=GetID()
function s.initial_effect(c)
  aux.AddCodeList(c,76200681)
	--act in set turn
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetValue(id)
	e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCondition(s.condition)
	e0:SetCost(s.cost)
	c:RegisterEffect(e0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--negate damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DRAW_PHASE,TIMING_DRAW_PHASE+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetRange(LOCATION_GRAVE+LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	--change effect target
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.cecon)
	e3:SetTarget(s.cetg)
	e3:SetOperation(s.ceop)
	c:RegisterEffect(e3)
end
function s.condition(e)
	return e:GetHandler():IsStatus(STATUS_SET_TURN) and e:GetHandler():IsLocation(LOCATION_ONFIELD)
end
function s.costfilter(c)
	return (c:IsType(TYPE_PENDULUM) or (c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,76200681))) and not c:IsPublic()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.pfilter(c,tp)
	return c:IsType(TYPE_TRAP+TYPE_CONTINUOUS) and aux.IsCodeListed(c,76200681)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil,tp) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
function s.cecon(e,tp,eg,ep,ev,re,r,rp)
	if e==re or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:GetCount()==1 and g:GetFirst()==e:GetHandler()
end
function s.cefilter(c,ct)
	return Duel.CheckChainTarget(ct,c)
end
function s.cetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.cefilter(chkc,ev) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(s.cefilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),ev) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.cefilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler(),ev)
end
function s.ceop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.ChangeTargetCard(ev,Group.FromCards(tc))
	end
end
