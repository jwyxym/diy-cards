--匿影的魔女 小神晶劳子
function c31280179.initial_effect(c)
	c:EnableReviveLimit()
	--手卡特召    
  	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31280179,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c31280179.condition)
	e1:SetOperation(c31280179.operation)
	c:RegisterEffect(e1)
	--效果耐性
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c31280179.value)
	c:RegisterEffect(e2)
	--效破抗性    
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--效果无效   
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(31280179,1))
	e4:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,31280179)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e4:SetCondition(c31280179.condition1)
	e4:SetCost(c31280179.cost1)
	e4:SetTarget(c31280179.target1)
	e4:SetOperation(c31280179.operation1)
	c:RegisterEffect(e4) 
end  
c31280179[0]=0     
function c31280179.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and Duel.GetFlagEffect(tp,31280179)==0
end
function c31280179.operation(e,tp,eg,ep,ev,re,r,rp)	
	local c=e:GetHandler()
    if 31280179==c31280179[0] or Duel.GetLocationCount(tp,LOCATION_MZONE)==0
		or not c:IsCanBeSpecialSummoned(e,0,tp,true,true) then return end
    c31280179[0]=31280179
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(31280179,2)) then
    	Duel.Hint(HINT_CARD,0,31280179)
    	if Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)~=0 then
        	c:CompleteProcedure()
        end    
    end 
    Duel.RegisterFlagEffect(tp,31280179,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)  
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c31280179.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end        
function c31280179.splimit(e,c)
	return c:IsCode(31280180)
end
function c31280179.value(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
function c31280179.condition1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) 
    	and Duel.GetTurnCount()~=e:GetHandler():GetFlagEffectLabel(31280179)
end
function c31280179.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function c31280179.nbfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c31280179.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and c31280179.nbfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c31280179.nbfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c31280179.nbfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function c31280179.operation1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
		Duel.AdjustInstantly()
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		Duel.Destroy(tc,REASON_EFFECT)
	end
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
		c:RegisterFlagEffect(31280179,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2,Duel.GetTurnCount()+1)
    end   
end