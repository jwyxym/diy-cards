--颂光的圣女 贞神崎月奈
function c31280180.initial_effect(c)
	c:EnableReviveLimit()
	--手卡特召    
  	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31280180,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c31280180.condition)
	e1:SetOperation(c31280180.operation)
	c:RegisterEffect(e1)
	--效果耐性
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c31280180.value)
	c:RegisterEffect(e2)
	--不被作为攻击对象    
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e3:SetValue(aux.imval1)
	c:RegisterEffect(e3)
	--抽卡   
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(31280180,1))
	e4:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,31280180)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e4:SetCondition(c31280180.condition1)
	e4:SetCost(c31280180.cost1)
	e4:SetTarget(c31280180.target1)
	e4:SetOperation(c31280180.operation1)
	c:RegisterEffect(e4) 
end    
c31280180[0]=0   
function c31280180.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
		and Duel.GetFlagEffect(tp,31280180)==0
end
function c31280180.operation(e,tp,eg,ep,ev,re,r,rp)	
	local c=e:GetHandler()
    if 31280180==c31280180[0] or Duel.GetLocationCount(tp,LOCATION_MZONE)==0
		or not c:IsCanBeSpecialSummoned(e,0,tp,true,true) then return end
    c31280180[0]=31280180
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(31280180,2)) then
    	Duel.Hint(HINT_CARD,0,31280180)
    	if Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)~=0 then
        	c:CompleteProcedure()
        end    
    end 
    Duel.RegisterFlagEffect(tp,31280180,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)  
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c31280180.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end        
function c31280180.splimit(e,c)
	return c:IsCode(31280179)
end
function c31280180.value(e,te)
	return te:GetOwner()~=e:GetHandler() and te:IsActiveType(TYPE_MONSTER)
end
function c31280180.condition1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and re:IsActiveType(TYPE_MONSTER) 
    	and Duel.GetTurnCount()~=e:GetHandler():GetFlagEffectLabel(31280180)
end
function c31280180.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function c31280180.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=Duel.GetCurrentChain()
		e:SetLabel(ct)
		return ct>0 and Duel.IsPlayerCanDraw(tp,ct)
	end
	Duel.SetTargetParam(e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
function c31280180.operation1(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetCurrentChain()
	local dc=Duel.Draw(tp,ct,REASON_EFFECT)
    if dc>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local rg=Duel.GetFieldGroup(tp,LOCATION_HAND,0):Select(tp,dc-1,dc-1,nil)
		Duel.ShuffleHand(tp)
		aux.PlaceCardsOnDeckBottom(tp,rg)
    end    
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
		c:RegisterFlagEffect(31280180,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2,Duel.GetTurnCount()+1)
    end   
end