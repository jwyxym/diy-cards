--械鳞龙魄 飓铁龙人
function c31280135.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--发动无效     
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(31280135,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c31280135.condition)
	e1:SetTarget(c31280135.target)
	e1:SetOperation(c31280135.operation)
	c:RegisterEffect(e1)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e7:SetRange(LOCATION_SZONE)
	e7:SetTargetRange(LOCATION_MZONE,0)
	e7:SetTarget(c31280135.eftg)
	e7:SetLabelObject(e1)
	c:RegisterEffect(e7)
	--改变种类
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_ADD_TYPE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(c31280135.eftg)
	e5:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_REMOVE_TYPE)
	e6:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e6)    
    --种族视为机械族
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_RACE)
	e2:SetRange(LOCATION_MZONE+LOCATION_HAND+LOCATION_EXTRA)
	e2:SetValue(RACE_MACHINE)
	c:RegisterEffect(e2) 
	--检索并贴p
    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,31280135)
	e3:SetTarget(c31280135.target1)
	e3:SetOperation(c31280135.operation1)
	c:RegisterEffect(e3) 
	--不会被取对象
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c31280135.condition1)
	e4:SetValue(c31280135.value)
	c:RegisterEffect(e4)        
end
function c31280135.defilter(c)
	return c:GetOriginalType()&TYPE_MONSTER>0
end
function c31280135.eftg(e,c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_RITUAL)
end
function c31280135.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) 
    	and Duel.IsChainNegatable(ev)
end
function c31280135.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    e:GetHandler():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(31280135,1))
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
    	local g=Duel.IsExistingMatchingCard(c31280135.defilter,tp,LOCATION_ONFIELD,0,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
function c31280135.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re:GetHandler():IsRelateToEffect(re) and Duel.NegateActivation(ev) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,c31280135.defilter,tp,LOCATION_ONFIELD,0,1,1,nil)
		Duel.HintSelection(g)
		Duel.BreakEffect()
		Duel.Destroy(g,REASON_EFFECT)              
	end    
end
function c31280135.thfilter(c,tp)
	return c:IsSetCard(0xca4) and c:IsType(TYPE_PENDULUM)
		and (not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE) or c:IsAbleToHand())
end               
function c31280135.thfilter2(c,g)
	return not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE) and g:FilterCount(Card.IsAbleToHand,c)==1
end
function c31280135.Group(g)
	return aux.dncheck(g) and g:FilterCount(c31280135.thfilter2,nil,g)~=0
end
function c31280135.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c31280135.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and g:CheckSubGroup(c31280135.Group,2,2) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c31280135.operation1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c31280135.thfilter,tp,LOCATION_DECK,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:SelectSubGroup(tp,c31280135.Group,false,2,2)
    if sg:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tc=sg:FilterSelect(tp,Card.IsAbleToHand,1,1,nil):GetFirst()
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
		sg:RemoveCard(tc)
		Duel.MoveToField(sg:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)        
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c31280135.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c31280135.splimit(e,c)
	return not (c:IsRace(RACE_MACHINE) and c:GetOriginalRace()==RACE_DRAGON) and c:IsLocation(LOCATION_EXTRA)
end
function c31280135.condition1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return false end
	local tg=g:GetMaxGroup(Card.GetAttack)
	return tg:IsExists(Card.IsControler,1,nil,tp)
end
function c31280135.value(e,re,rp)
	return rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end