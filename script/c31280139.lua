--械鳞龙魄 汞合金装甲龙
function c31280139.initial_effect(c)
	--连接召唤	
	aux.AddLinkProcedure(c,c31280139.mfilter,2,2)
    c:EnableReviveLimit()
    --种族视为机械族
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_RACE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_EXTRA)
	e1:SetValue(RACE_MACHINE)
	c:RegisterEffect(e1)  
	--特召伤害    
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c31280139.condition)
	e2:SetOperation(c31280139.operation)
	c:RegisterEffect(e2)  
	--回收升攻   
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
   	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,31280139)
    e3:SetCondition(c31280139.condition1)
	e3:SetTarget(c31280139.target1)
	e3:SetOperation(c31280139.operation1)
	c:RegisterEffect(e3)     
end    
function c31280139.mfilter(c)
	return c:IsLinkRace(RACE_DRAGON) and c:IsType(TYPE_PENDULUM)
end
function c31280139.filter(c,sp)
	return c:IsSummonPlayer(sp) and c:IsSummonLocation(LOCATION_EXTRA)
end
function c31280139.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return false end
	local tg=g:GetMaxGroup(Card.GetAttack)
	return eg:IsExists(c31280139.filter,1,nil,1-tp)
		and not Duel.IsChainSolving() and tg:IsExists(Card.IsControler,1,nil,tp)
end
function c31280139.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,31280139)
	Duel.Damage(1-tp,400,REASON_EFFECT)
end
function c31280139.condition1(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and e:GetHandler():GetLinkedGroupCount()>0
end
function c31280139.thfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xca4) and c:IsAbleToHand() and c:GetOriginalType()&TYPE_MONSTER>0
end		
function c31280139.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xca4)
end
function c31280139.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c31280139.atkfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c31280139.thfilter,tp,LOCATION_ONFIELD+LOCATION_EXTRA,0,1,nil) 
    	and Duel.IsExistingTarget(c31280139.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD+LOCATION_EXTRA)
	Duel.SelectTarget(tp,c31280139.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c31280139.operation1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c31280139.thfilter,tp,LOCATION_ONFIELD+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		local tc=Duel.GetFirstTarget()
		if tc:IsFaceup() and tc:IsRelateToEffect(e) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end            
	end
end