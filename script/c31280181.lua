--黑苍之绊·法露特与米莉亚姆
function c31280181.initial_effect(c)
	--连接召唤
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_DRAGON),2,3,c31280181.lcheck)
	c:EnableReviveLimit()
    --种族视为机械族
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_RACE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_EXTRA)
	e1:SetValue(RACE_MACHINE)
	c:RegisterEffect(e1)  
	--属性视为光    
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_ATTRIBUTE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_EXTRA)
	e2:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e2)   
	--回手特召    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31280181,0))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,31280181)
	e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCondition(c31280181.condition)
	e3:SetTarget(c31280181.target)
	e3:SetOperation(c31280181.operation)
	c:RegisterEffect(e3)
	--多次攻击     
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EXTRA_ATTACK)
	e4:SetCondition(c31280181.condition1)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--回复
    local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(31280181,2))
	e5:SetCategory(CATEGORY_RECOVER)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EVENT_BATTLE_DAMAGE)
    e5:SetCondition(c31280181.condition2)
	e5:SetTarget(c31280181.target2)
	e5:SetOperation(c31280181.operation2)
	c:RegisterEffect(e5)
	--特召无效
    local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(31280181,3))
	e6:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_SPSUMMON)
	e6:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(c31280181.condition3)
	e6:SetTarget(c31280181.target3)
	e6:SetOperation(c31280181.operation3)
	c:RegisterEffect(e6)    
end    
function c31280181.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_LINK)
end
function c31280181.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c31280181.thfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
function c31280181.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280181.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA)
end
function c31280181.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c31280181.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
        local sg=g:GetFirst()
        if sg:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and sg:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.SelectYesNo(tp,aux.Stringid(31280181,1)) then
        	Duel.BreakEffect()
			if Duel.SpecialSummonStep(sg,0,tp,tp,false,false,POS_FACEUP) then
            	local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sg:RegisterEffect(e1)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				sg:RegisterEffect(e2)
                local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_UPDATE_ATTACK)
				e3:SetValue(1400)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
				sg:RegisterEffect(e3)
			end
			Duel.SpecialSummonComplete()
        end        
	end
end
function c31280181.condition1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLinkedGroupCount()>0
end
function c31280181.condition2(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and e:GetHandler():GetLinkedGroupCount()>0
end
function c31280181.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ev)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,0,0,tp,ev)
end
function c31280181.operation2(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end
function c31280181.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA)
end
function c31280181.condition3(e,tp,eg,ep,ev,re,r,rp)
	return tp~=ep and eg:IsExists(c31280181.cfilter,1,nil,1-tp) and Duel.GetCurrentChain()==0
		and e:GetHandler():GetLinkedGroupCount()>0
end
function c31280181.target3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    e:GetHandler():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(31280181,4))
	local g=eg:Filter(c31280181.cfilter,nil,1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function c31280181.operation3(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c31280181.cfilter,nil,1-tp)
	Duel.NegateSummon(g)
	Duel.Destroy(g,REASON_EFFECT)
end