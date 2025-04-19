--深池侦察犬
function c31280317.initial_effect(c)
	--特召
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,31280317+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c31280317.condition)
	e1:SetOperation(c31280317.operation)
	c:RegisterEffect(e1)
    --墓地回手
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
    e2:SetCountLimit(1,31380317)
	e2:SetCondition(c31280317.condition1)
	e2:SetCost(c31280317.cost1)
	e2:SetTarget(c31280317.target1)
	e2:SetOperation(c31280317.operation1)
	c:RegisterEffect(e2)
end
function c31280317.spfilter(c)
	return c:IsSetCard(0xca3) and c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
function c31280317.condition(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetMatchingGroupCount(c31280317.spfilter,tp,LOCATION_MZONE,0,nil)>0
end
function c31280317.operation(e,tp,eg,ep,ev,re,r,rp,c)
	--自肃        
	local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_EXTRA_MATERIAL)
    e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetTargetRange(LOCATION_ONFIELD+LOCATION_HAND,0)
    e1:SetTarget(function(_,c)
        return c:IsSetCard(0xca3) and c:IsType(TYPE_MONSTER)
    end)
    e1:SetValue(1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetTargetRange(LOCATION_ONFIELD+LOCATION_HAND,0)
    e2:SetTarget(function(_,c)
        return not c:IsSetCard(0xca3)
    end)
    e2:SetValue(1)
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2,tp)
        
    local e3=e2:Clone()
    e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    Duel.RegisterEffect(e3,tp)
end
function c31280317.condition1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsPreviousLocation(LOCATION_ONFIELD)
end
function c31280317.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
function c31280317.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function c31280317.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end