--不朽机骸 死骸金属巨星
function c31280117.initial_effect(c)
	--融合召唤
	aux.AddFusionProcMix(c,false,true,c31280117.fusfilter1,c31280117.fusfilter2,c31280117.fusfilter3)
    aux.AddContactFusionProcedure(c,aux.FilterBoolFunction(Card.IsReleasable,REASON_SPSUMMON),LOCATION_MZONE,0,Duel.Release,REASON_SPSUMMON+REASON_MATERIAL)
	c:EnableReviveLimit()
	--特召条件
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c31280117.splimit)
	c:RegisterEffect(e1)
    --种族视为机械族
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_RACE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_EXTRA)
	e2:SetValue(RACE_MACHINE)
	c:RegisterEffect(e2)
	--直接攻击    
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e3)    
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c31280117.condition)
	e4:SetValue(-1000)
	c:RegisterEffect(e4)
	--生token    
    local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,31280117)
	e5:SetCost(c31280117.cost)
	e5:SetTarget(c31280117.target)
	e5:SetOperation(c31280117.operation)
	c:RegisterEffect(e5)
	--墓地或除外特召   
    local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(74892653,2))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_LEAVE_FIELD)
    e6:SetCountLimit(1,31380117)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCondition(c31280117.condition1)
	e6:SetTarget(c31280117.target1)
	e6:SetOperation(c31280117.operation1)
	c:RegisterEffect(e6)
end    
function c31280117.fusfilter1(c)
	return c:IsFusionType(TYPE_FUSION) and c:IsRace(RACE_ZOMBIE)
end
function c31280117.fusfilter2(c)
	return c:IsSetCard(0xca2)
end
function c31280117.fusfilter3(c)
	return c:IsRace(RACE_MACHINE)
end
function c31280117.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
function c31280117.condition(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
		and Duel.GetAttackTarget()==nil and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)~=0
		and e:GetHandler():GetEffectCount(EFFECT_DIRECT_ATTACK)==1
end
function c31280117.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtraAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,0,REASON_COST)
end
function c31280117.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonMonster(tp,31380121,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_MACHINE,ATTRIBUTE_LIGHT) end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function c31280117.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=3
	if ft>0 and ct>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,31380121,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_MACHINE,ATTRIBUTE_LIGHT) then
   	    local count=math.min(ft,ct)
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then count=1 end
		if count>1 then
			local num={}
			local i=1
			while i<=count do
				num[i]=i
				i=i+1
			end
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(31280117,0))
			count=Duel.AnnounceNumber(tp,table.unpack(num))
		end
		repeat
			local token=Duel.CreateToken(tp,31380121)
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
			count=count-1
		until count==0
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c31280117.splimit1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c31280117.splimit1(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
function c31280117.condition1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
function c31280117.sfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE+RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(31280117)
end
function c31280117.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c31280117.sfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function c31280117.operation1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c31280117.sfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end