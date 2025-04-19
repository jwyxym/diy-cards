--深池暗影术师
function c31280313.initial_effect(c)
	--卡组检索
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,31280313)
	e1:SetTarget(c31280313.target)
	e1:SetOperation(c31280313.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--效破抗性
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetCondition(c31280313.condition1)
    e3:SetTarget(c31280313.target1)
	e3:SetValue(c31280313.value1)
	c:RegisterEffect(e2)
end
function c31280313.thfilter(c)
	return c:IsSetCard(0xca3) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function c31280313.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280313.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c31280313.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c31280313.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
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
function c31280313.indfilter(c)
	return c:IsPublic() and c:IsRace(RACE_DRAGON)
end
function c31280313.condition1(e)
	return Duel.IsExistingMatchingCard(c31280313.indfilter,tp,LOCATION_HAND,0,1,nil)
end
function c31280313.target1(e,c)
	return c:IsFaceup() and c:IsSetCard(0xca3) and c:IsStatus(STATUS_SPSUMMON_TURN)
end
function c31280313.value1(e,re,r,rp)
	if bit.band(r,REASON_EFFECT)~=0 and re:GetType()==TYPE_SPELL then
		return 1
	else return 0 end
end