--创造的丹紫·安涅儿
function c31280118.initial_effect(c)
	aux.AddCodeList(c,31280120)
	--融合召唤
	aux.AddFusionProcMix(c,false,true,31280120,c31280118.fusfilter1,c31280118.fusfilter2)
	c:EnableReviveLimit()
	--特召代价
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_COST)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCost(c31280118.spcost)
	c:RegisterEffect(e1)
    --种族视为机械族
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_RACE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_EXTRA)
	e2:SetValue(RACE_MACHINE)
	c:RegisterEffect(e2)
	--额外特召    
    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,31280118)
	e3:SetTarget(c31280118.target)
	e3:SetOperation(c31280118.operation)
    c:RegisterEffect(e3)
	--墓地特召    
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31280118,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCountLimit(1,31380118)
    e4:SetCondition(c31280118.condition1)
	e4:SetTarget(c31280118.target1)
	e4:SetOperation(c31280118.operation1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(c31280118.condition2)
	c:RegisterEffect(e5)
end    
function c31280118.fusfilter1(c)
	return c:IsRace(RACE_ZOMBIE)
end
function c31280118.fusfilter2(c)
	return c:IsRace(RACE_MACHINE)
end
function c31280118.cfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsFaceup()
end
function c31280118.spcost(e,c,tp,st)
	if st&SUMMON_TYPE_FUSION~=SUMMON_TYPE_FUSION then return true end
	return Duel.IsExistingMatchingCard(c31280118.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
function c31280118.spfilter(c,e,tp)
	return c:IsCode(31280122) and c:IsCanBeSpecialSummoned(e,0,tp,false,true) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function c31280118.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280118.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c31280118.operation(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetFirstMatchingCard(c31280118.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if tg and Duel.SpecialSummon(tg,0,tp,tp,false,true,POS_FACEUP) then
    	local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c31280120.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function c31280118.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
function c31280118.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c31280118.cfilter1(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsControler(tp) and c:IsRace(RACE_ZOMBIE)
end
function c31280118.condition2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31280118.cfilter1,1,nil,tp)
end
function c31280118.filter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and Duel.IsExistingMatchingCard(c31280118.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode()) and not c:IsCode(31280118)
end
function c31280118.spfilter1(c,e,tp,code)
	return c:IsRace(RACE_ZOMBIE) and c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c31280118.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31280118.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c31280118.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,c31280118.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c31280118.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,c31280118.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetCode())
		if g:GetCount()>0 then
        	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end