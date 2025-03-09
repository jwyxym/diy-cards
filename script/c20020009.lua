--
function c20020009.initial_effect(c)
	--spsummon
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(20020009,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e0:SetCountLimit(1,20020009)
	e0:SetTarget(c20020009.sptg)
	e0:SetOperation(c20020009.spop)
	c:RegisterEffect(e0)
	c20020009.sps_effect=e0
	--Activate(summon)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCondition(aux.NegateSummonCondition)
	e1:SetCost(c20020009.cost)
	e1:SetTarget(c20020009.target)
	e1:SetOperation(c20020009.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
	--Effect monster
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_ADD_TYPE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e4)
end
function c20020009.spfilter(c,e,tp)
	return c:IsSetCard(0xb35) and c:IsType(TYPE_TRAP) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function c20020009.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c20020009.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c20020009.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c20020009.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if g:GetCount()>0 and tc then
		tc:AddMonsterAttribute(TYPE_MONSTER)
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c20020009.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c20020009.splimit(e,c)
	return not c:IsSetCard(0xb35) and c:IsLocation(LOCATION_EXTRA)
end
function c20020009.cfilter(c,tp)
	return c:IsSetCard(0xb35) and (c:IsControler(tp) or c:IsFaceup()) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function c20020009.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c20020009.cfilter,1,nil,tp) end
	local sg=Duel.SelectReleaseGroup(tp,c20020009.cfilter,1,1,nil,tp)
	Duel.Release(sg,REASON_COST)
end
function c20020009.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
function c20020009.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
end