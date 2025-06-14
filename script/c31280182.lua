--烈霸工匠·蕾吉
function c31280182.initial_effect(c)
	--连接召唤
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(c31280182.matfilter,RACE_DRAGON),2,99)
    c:EnableReviveLimit()
    --种族视为机械族
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_RACE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_EXTRA)
	e1:SetValue(RACE_MACHINE)
	c:RegisterEffect(e1)    
	--手卡或额外特召    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31280182,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,31280182)
	e2:SetCondition(c31280182.condition)
	e2:SetTarget(c31280182.target)
	e2:SetOperation(c31280182.operation)
	c:RegisterEffect(e2)
	--无效并加攻    
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(31280182,1))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,31280182)
	e3:SetCondition(c31280182.condition1)
    e3:SetCost(c31280182.cost1)
	e3:SetTarget(c31280182.target1)
	e3:SetOperation(c31280182.operation1)
	c:RegisterEffect(e3)
end
function c31280182.matfilter(c)
	return c:IsRace(RACE_MACHINE)
end
function c31280182.cfilter(c)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) 
    	and c:GetOriginalType()&TYPE_MONSTER>0
end
function c31280182.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31280182.cfilter,1,e:GetHandler())
end
function c31280182.spfilter(c,e,tp)
	return (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
		and c:IsSetCard(0xca4,0xca6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and (not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
function c31280182.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280182.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA)
end
function c31280182.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c31280182.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c31280182.condition1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and e:GetHandler():GetLinkedGroupCount()>0
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function c31280182.costfilter(c)
	return c:IsRace(RACE_MACHINE) and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA)) and c:IsAbleToDeckOrExtraAsCost()
end
function c31280182.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c31280182.costfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c31280182.costfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,2,2,nil)
	Duel.HintSelection(g)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function c31280182.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function c31280182.atkfilter(c,e)
	return c:IsFaceup() and not c:IsImmuneToEffect(e)
end
function c31280182.operation1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then    	
    	local c=e:GetHandler()
		local g=Duel.GetMatchingGroup(c31280182.atkfilter,tp,LOCATION_MZONE,0,nil,e)
		if g:GetCount()>0 then       
        	Duel.BreakEffect()	
			for tc in aux.Next(g) do
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(400)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
            end    
		end
	end
end