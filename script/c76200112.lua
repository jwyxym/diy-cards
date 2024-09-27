--炽神界之殿
local cm,m,o=GetID()
function cm.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Trap activate in set turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetCondition(cm.con2)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x721))
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(cm.con3)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
		--recover
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(2,m+5)
	e3:SetCondition(cm.con)
	e3:SetTarget(cm.tg)
	e3:SetOperation(cm.op)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_F)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EVENT_BECOME_TARGET)
	e4:SetCondition(cm.con1)
	e4:SetTarget(cm.tg1)
	e4:SetOperation(cm.op1)
	c:RegisterEffect(e4)
end
function cm.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.CheckLPCost(tp,700)
end
function cm.con3(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and re:GetHandler():IsType(TYPE_TRAP) and re:GetHandler():IsSetCard(0x721) and re:GetHandler():IsStatus(STATUS_SET_TURN)
end
function cm.op2(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.PayLPCost(tp,700)
end
function cm.cfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsSummonPlayer(tp)
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)
	return eg:Filter(cm.cfilter,nil,tp):GetCount()==1
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(eg:Filter(cm.cfilter,nil,tp):GetFirst():GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,eg:Filter(cm.cfilter,nil,tp):GetFirst():GetAttack())
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end
function cm.con1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
function cm.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function cm.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Destroy(c,REASON_EFFECT)
	end
end