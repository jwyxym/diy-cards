--混融的继承者 莎木·纳克雅
function c38030168.initial_effect(c)
	c:EnableCounterPermit(0x612)
	c:EnableReviveLimit()
	--cannot special summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)
	--special summon
	local se0=Effect.CreateEffect(c)
	se0:SetType(EFFECT_TYPE_FIELD)
	se0:SetCode(EFFECT_SPSUMMON_PROC)
	se0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	se0:SetRange(LOCATION_HAND)
	se0:SetCondition(c38030168.sprcon)
	c:RegisterEffect(se0)
	--win
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c38030168.winop)
	c:RegisterEffect(e1)
	--counter
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38030168,1))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,38030168)
	e2:SetCondition(c38030168.icon)
	e2:SetCost(c38030168.ctcost)
	e2:SetTarget(c38030168.cttg)
	e2:SetOperation(c38030168.ctop)
	c:RegisterEffect(e2)
	local e0=e2:Clone()
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCondition(c38030168.qcon)
	c:RegisterEffect(e0)
	--control
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38030168,2))
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,38030168+1)
	e3:SetCondition(c38030168.icon)
	e3:SetCost(c38030168.ctrcost)
	e3:SetTarget(c38030168.ctrtg)
	e3:SetOperation(c38030168.ctrop)
	c:RegisterEffect(e3)
	local e0=e3:Clone()
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCondition(c38030168.qcon)
	c:RegisterEffect(e0)
	--immune
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c38030168.immcon)
	e4:SetValue(c38030168.efilter)
	c:RegisterEffect(e4)
	--indes
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c38030168.immcon)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
function c38030168.sprcon(e,c)
	if c==nil then return true end
	return Duel.GetMZoneCount(c:GetControler())>0 and Duel.GetCounter(c:GetControler(),1,0,0x611)>=10
end
function c38030168.icon(e,tp,eg,ep,ev,re,r,rp)
	return not (Duel.IsPlayerAffectedByEffect(tp,38030153)~=nil and e:GetHandler():IsOriginalSetCard(0x5616))
end
function c38030168.qcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerAffectedByEffect(tp,38030153)~=nil and e:GetHandler():IsOriginalSetCard(0x5616)
end
function c38030168.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x611,10,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x611,10,REASON_COST)
end
function c38030168.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x612,1) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x612)
end
function c38030168.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		c:AddCounter(0x612,1)
	end
end
function c38030168.ctrcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function c38030168.ctrtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function c38030168.ctrop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
function c38030168.winop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_SAMU = 0x38
	local c=e:GetHandler()
	if c:GetCounter(0x612)==4 then Duel.Win(tp,WIN_REASON_SAMU) end
end
function c38030168.immcon(e)
	return e:GetHandler():GetCounter(0x612)>0
end
function c38030168.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
