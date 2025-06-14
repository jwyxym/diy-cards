--械鳞龙魄 机关美人鱼
function c31280137.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--攻击上升    
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,31280137)
	e1:SetTarget(c31280137.target)
	e1:SetOperation(c31280137.operation)
	c:RegisterEffect(e1)
    --种族视为机械族
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_RACE)
	e2:SetRange(LOCATION_MZONE+LOCATION_HAND+LOCATION_EXTRA)
	e2:SetValue(RACE_MACHINE)
	c:RegisterEffect(e2)
	--手卡特召 
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(31280137,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,31380137)
	e3:SetCondition(c31280137.condition1)
	e3:SetTarget(c31280137.target1)
	e3:SetOperation(c31280137.operation1)
	c:RegisterEffect(e3)
	--直接攻击    
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(c31280137.condition2)
	c:RegisterEffect(e4)
end
function c31280137.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xca4)
end
function c31280137.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c31280137.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c31280137.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c31280137.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c31280137.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
        if c:IsRelateToEffect(e) then
        	Duel.BreakEffect()
			Duel.Destroy(c,REASON_EFFECT)
		end            
	end
end
function c31280137.cfilter(c)
	return c:IsSetCard(0xca4) and c:IsFaceup()
end
function c31280137.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c31280137.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c31280137.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c31280137.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		local tg=g:GetMaxGroup(Card.GetAttack)
    	if tg:IsExists(Card.IsControler,1,nil,tp) then    
        	Duel.BreakEffect() 	
       		local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetTargetRange(0,1)
			e1:SetValue(c31280137.value)
			e1:SetCondition(c31280137.condition)
        	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end              
	end
end
function c31280137.value(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function c31280137.condition(e)
	return Duel.GetAttacker()==e:GetHandler() 
end
function c31280137.cfilter1(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_MONSTER)
end
function c31280137.condition2(e)
	return Duel.IsExistingMatchingCard(c31280137.cfilter1,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,e:GetHandler())
end