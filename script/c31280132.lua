--械鳞龙魄 灭炮龙人
function c31280132.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--攻守下降    
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c31280132.value)
	c:RegisterEffect(e1)
    --种族视为机械族
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_RACE)
	e2:SetRange(LOCATION_MZONE+LOCATION_HAND+LOCATION_EXTRA)
	e2:SetValue(RACE_MACHINE)
	c:RegisterEffect(e2)
	--攻击下降       
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31280132,0))
    e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
   	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,31280132)
    e3:SetCondition(c31280132.condition)
	e3:SetTarget(c31280132.target)
	e3:SetOperation(c31280132.operation)
	c:RegisterEffect(e3)
	--怪兽破坏 
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31280132,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCountLimit(1,31380132)
    e4:SetCondition(c31280132.condition1)
	e4:SetTarget(c31280132.target1)
	e4:SetOperation(c31280132.operation1)
	c:RegisterEffect(e4)
end    
function c31280132.atkfilter(c)
	return c:IsSetCard(0xca4) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
function c31280132.value(e,c)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(c31280132.atkfilter,tp,LOCATION_MZONE,0,nil)
	return g:GetCount()*(-200)
end
function c31280132.condition(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
function c31280132.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
function c31280132.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c31280132.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c31280132.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c31280132.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
function c31280132.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function c31280132.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xca4) and c:IsType(TYPE_MONSTER)
end
function c31280132.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c31280132.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,e:GetHandler()) and eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
function c31280132.defilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
function c31280132.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c31280132.defilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack()) end
	local g=Duel.GetMatchingGroup(c31280132.defilter,tp,0,LOCATION_MZONE,nil,c:GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function c31280132.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() 
    	or not Duel.IsExistingMatchingCard(c31280132.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,e:GetHandler()) then return end
	local g=Duel.GetMatchingGroup(c31280132.defilter,tp,0,LOCATION_MZONE,nil,c:GetAttack())
	if g:GetCount()>0 then 
    	Duel.Destroy(g,REASON_EFFECT)
    end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	c:RegisterEffect(e1)
end