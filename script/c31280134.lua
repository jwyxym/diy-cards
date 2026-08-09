--械鳞龙魄 机装潜将
function c31280134.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--生token    
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,31280134)
	e1:SetTarget(c31280134.target)
	e1:SetOperation(c31280134.operation)
	c:RegisterEffect(e1)
    --种族视为机械族
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_RACE)
	e2:SetRange(LOCATION_MZONE+LOCATION_HAND+LOCATION_EXTRA)
	e2:SetValue(RACE_MACHINE)
	c:RegisterEffect(e2)
	--特殊召唤
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31280134,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,31380134)
	e3:SetTarget(c31280134.target1)
	e3:SetOperation(c31280134.operation1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	--效果改变
    local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(31280134,1))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,31280130)
	e5:SetCondition(c31280134.condition2)
	e5:SetCost(c31280134.cost2)
	e5:SetTarget(c31280134.target2)
	e5:SetOperation(c31280134.operation2)
	c:RegisterEffect(e5)              
end
function c31280134.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31380121,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_MACHINE,ATTRIBUTE_LIGHT) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function c31280134.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31380121,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_MACHINE,ATTRIBUTE_LIGHT) then
		local token=Duel.CreateToken(tp,31380121)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		if c:IsRelateToEffect(e) then
        	Duel.BreakEffect()
			Duel.Destroy(c,REASON_EFFECT)
		end            
	end
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c31280134.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)  
end
function c31280134.splimit(e,c)
	return not (c:IsRace(RACE_MACHINE) and c:GetOriginalRace()==RACE_DRAGON) and c:IsLocation(LOCATION_EXTRA)
end
function c31280134.spfilter(c,e,tp)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0xca4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and ((c:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
			or (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0))
end
function c31280134.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280134.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
function c31280134.operation1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c31280134.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c31280134.condition2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or ep==tp then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and (tg~=nil or tc>0)
end
function c31280134.costcfilter(c,tp)
	return (c:IsRace(RACE_MACHINE) and c:GetOriginalRace()==RACE_DRAGON) and Duel.GetMZoneCount(tp,c)>0
end
function c31280134.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c31280134.costcfilter,1,nil,tp) end
	local g=Duel.SelectReleaseGroup(tp,c31280134.costcfilter,1,1,nil,tp)
	Duel.Release(g,REASON_COST)
end
function c31280134.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
function c31280134.operation2(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,c31280134.operation3)
end
function c31280134.atkfilter(c,e)
	return c:IsFaceup() and not c:IsImmuneToEffect(e)
end
function c31280134.operation3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c31280134.atkfilter,tp,0,LOCATION_MZONE,nil,e)
	if g:GetCount()>0 then
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