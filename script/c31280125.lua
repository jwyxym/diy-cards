--圆滚滚1号
function c31280125.initial_effect(c)
	aux.AddCodeList(c,31280120)
	--手卡特召
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,31280125+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c31280125.condition)
	c:RegisterEffect(e1)
	--代替破坏    
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetTarget(c31280125.target)
	e2:SetValue(c31280125.value)
	e2:SetOperation(c31280125.operation)
	c:RegisterEffect(e2)
end
function c31280125.spfilter(c)
	return (c:IsCode(31280120) or aux.IsCodeListed(c,31280120)) and c:IsFaceupEx() and c:IsType(TYPE_MONSTER)
end
function c31280125.condition(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetMatchingGroupCount(c31280125.spfilter,tp,LOCATION_MZONE,0,nil)>0
end
function c31280125.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xca2) and not c:IsCode(31280125)
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
function c31280125.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and eg:IsExists(c31280125.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function c31280125.value(e,c)
	return c31280125.repfilter(c,e:GetHandlerPlayer())
end
function c31280125.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end