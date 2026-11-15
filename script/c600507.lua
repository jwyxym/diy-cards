--R A S·宴会似曲
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+id)
	e3:SetCondition(s.reccon)
	e3:SetTarget(s.rectg)
	e3:SetOperation(s.recop)
	c:RegisterEffect(e3)
	local eff=Effect.CreateEffect(c)
	eff:SetDescription(aux.Stringid(id,1))
	eff:SetCategory(CATEGORY_RECOVER+CATEGORY_TODECK)
	eff:SetType(EFFECT_TYPE_QUICK_O)
	eff:SetCode(EVENT_FREE_CHAIN)
	eff:SetRange(LOCATION_MZONE)
	eff:SetCountLimit(1)
	eff:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	eff:SetCondition(s.effcon)
	eff:SetCost(s.cost)
	eff:SetTarget(s.target)
	eff:SetOperation(s.operation)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.eftg)
	e4:SetLabelObject(eff)
	c:RegisterEffect(e4)
end

function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return rc~=e:GetHandler() and rc:IsSetCard(0xf00)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf09) and not c:IsSummonLocation(LOCATION_EXTRA)
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil):GetClassCount(Card.GetCode)>4
end

-- 效果2: 回复目标
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
		return s.check(g)
	end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	local atk=g:GetSum(Card.GetAttack)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,atk)
end

-- 效果2: 回复操作
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	if s.check(g) then
		local atk=g:GetSum(Card.GetAttack)
		Duel.Recover(tp,atk,REASON_EFFECT)
	end
end
function s.eftg(e,c)
	return c:IsSetCard(0xf09) and c:IsType(TYPE_MONSTER)
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp or Duel.GetTurnPlayer()==1-tp
end
function s.costfilter(c)
	return c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2000)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2000)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end