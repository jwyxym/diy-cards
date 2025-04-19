--深池狙击手
function c31280315.initial_effect(c)
	--手卡特召
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,31280315)
	e1:SetCondition(c31280315.condition)
	e1:SetTarget(c31280315.target)
	e1:SetOperation(c31280315.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
    --攻击变化
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetCondition(c31280315.condition1)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	--直接攻击    
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(c31280315.condition2)
	c:RegisterEffect(e4)
end
function c31280315.spfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsFaceup() and c:IsSetCard(0xca3)
end
function c31280315.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31280315.spfilter,1,nil,tp)
end
function c31280315.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c31280315.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
 	end        
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
function c31280315.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xca3)
end
function c31280315.condition1(e)
	return Duel.IsExistingMatchingCard(c31280315.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,e:GetHandler())
end
function c31280315.condition2(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(c31280315.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end