--深池重甲卫士
function c31280316.initial_effect(c)
	--卡组送墓
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,31280316)
	e1:SetTarget(c31280316.target)
	e1:SetOperation(c31280316.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--战破抗性    
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetCountLimit(1)
	e3:SetValue(c31280316.value)
	c:RegisterEffect(e3)
end
function c31280316.tgfilter(c)
	return c:IsSetCard(0xca3) and not c:IsCode(31280316) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function c31280316.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280316.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c31280316.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c31280316.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
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
function c31280316.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xca3)
end
function c31280316.value(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0 and Duel.IsExistingMatchingCard(c31280316.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,e:GetHandler())
end