--钢甲龙骑士·拜伦
function c31280131.initial_effect(c)
	aux.AddCodeList(c,31280140)
	aux.EnablePendulumAttribute(c)
	aux.EnableReviveLimitPendulumSummonable(c,LOCATION_HAND)
	--特召条件    
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	--卡组特召
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,31280131)
	e2:SetCost(c31280131.cost)
	e2:SetTarget(c31280131.target)
	e2:SetOperation(c31280131.operation)
	c:RegisterEffect(e2)
    --种族视为机械族
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_ADD_RACE)
	e3:SetRange(LOCATION_MZONE+LOCATION_HAND+LOCATION_EXTRA)
	e3:SetValue(RACE_MACHINE)
	c:RegisterEffect(e3)
	--卡组检索  
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31280131,0))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCountLimit(1,31380131)
    e4:SetCondition(c31280131.condition1)
	e4:SetTarget(c31280131.target1)
	e4:SetOperation(c31280131.operation1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c31280131.condition2)
	c:RegisterEffect(e5)
	--额外回手    
    local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(31280131,1))
	e6:SetCategory(CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e6:SetCountLimit(1,31380131)
    e6:SetCondition(c31280131.condition1)
	e6:SetTarget(c31280131.target2)
	e6:SetOperation(c31280131.operation2)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_LEAVE_FIELD)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(c31280131.condition2)
	c:RegisterEffect(e7)
	--p区特召  
    local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(31280131,2))
	e8:SetCategory(CATEGORY_TOHAND)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_SPSUMMON_SUCCESS)
	e8:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e8:SetCountLimit(1,31380131)
    e8:SetCondition(c31280131.condition1)
	e8:SetTarget(c31280131.target3)
	e8:SetOperation(c31280131.operation3)
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e9:SetCode(EVENT_LEAVE_FIELD)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCondition(c31280131.condition2)
	c:RegisterEffect(e9)
	--攻击上升 
    local e10=Effect.CreateEffect(c)
	e10:SetCategory(CATEGORY_ATKCHANGE)
	e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e10:SetProperty(EFFECT_FLAG_DELAY)
	e10:SetRange(LOCATION_MZONE)
	e10:SetCode(EVENT_SUMMON_SUCCESS)
	e10:SetCondition(c31280131.condition4)
	e10:SetOperation(c31280131.operation4)
	c:RegisterEffect(e10)
	local e11=e10:Clone()
	e11:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e11)
	--伪全抗
    local e12=Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_FIELD)
	e12:SetCode(EFFECT_IMMUNE_EFFECT)
	e12:SetRange(LOCATION_MZONE)
	e12:SetTargetRange(LOCATION_MZONE,0)
	e12:SetTarget(c31280131.target4)
	e12:SetValue(c31280131.value4)
	c:RegisterEffect(e12)   
end
function c31280131.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function c31280131.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function c31280131.spfilter(c,e,tp)
	return c:IsSetCard(0xca4) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not Duel.IsExistingMatchingCard(c31280131.cfilter,tp,LOCATION_ONFIELD+LOCATION_EXTRA,0,1,nil,c:GetCode())
end
function c31280131.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c31280131.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c31280131.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c31280131.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        if c:IsRelateToEffect(e) then
        	Duel.BreakEffect()
			Duel.Destroy(c,REASON_EFFECT)
		end            
	end
end
function c31280131.cfilter1(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetOriginalType()&TYPE_MONSTER>0
    	and c:IsRace(RACE_DRAGON)
end
function c31280131.condition1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function c31280131.condition2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31280131.cfilter1,1,nil,tp)
end
function c31280131.thfilter(c)
	return c:IsSetCard(0xca4) and c:IsAbleToHand()
end
function c31280131.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280131.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c31280131.operation1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c31280131.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c31280131.thfilter1(c)
	return c:IsFaceup() and (c:IsRace(RACE_MACHINE) and c:GetOriginalRace()==RACE_DRAGON) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function c31280131.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280131.thfilter1,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function c31280131.operation2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c31280131.thfilter1,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
function c31280131.spfilter1(c,e,tp)
	return c:IsSetCard(0xca4) and c:GetOriginalType()&TYPE_MONSTER>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c31280131.target3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and c31280131.spfilter1(chkc,e,tp,c) end
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c31280131.spfilter1,tp,LOCATION_PZONE,0,1,nil,e,tp,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c31280131.spfilter1,tp,LOCATION_PZONE,0,1,1,nil,e,tp,c)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c31280131.operation3(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
    	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end   
end
function c31280131.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
function c31280131.condition4(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31280131.cfilter2,1,tp) and not eg:IsContains(e:GetHandler())
end
function c31280131.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
function c31280131.operation4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c31280131.atkfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
        tc=g:GetNext()
	end
end
function c31280131.target4(e,c)
	return c:IsRace(RACE_MACHINE)
end
function c31280131.value4(e,te)
	return te:GetOwner()~=e:GetHandler() and te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
		and te:GetOwner():GetAttack()<=e:GetHandler():GetAttack() and te:IsActivated()
end