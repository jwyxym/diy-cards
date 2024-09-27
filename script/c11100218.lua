--极巧机冶·重炼
function c11100218.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11100218,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,11100218)
	e1:SetCost(c11100218.cost2)
	e1:SetTarget(c11100218.tg2)
	e1:SetOperation(c11100218.op2)
	c:RegisterEffect(e1)
	--atk & def
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11100218,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,11100218+1)
	e2:SetCondition(c11100218.atkcon)
	e2:SetOperation(c11100218.atkop)
	c:RegisterEffect(e2)
end
function c11100218.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function c11100218.tg2f1(c,e,tp)
	return c:IsRace(RACE_MACHINE) and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExistingMatchingCard(c11100218.tg2f2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
function c11100218.tg2f2(c,e,tp,code)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and aux.AtkEqualsDef(c)
		and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c11100218.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.CheckReleaseGroup(tp,c11100218.tg2f1,1,nil,e,tp)
	end
	local rg=Duel.SelectReleaseGroup(tp,c11100218.tg2f1,1,1,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetCode())
	Duel.Release(rg,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c11100218.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local code=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c11100218.tg2f2,tp,LOCATION_DECK,0,1,1,nil,e,tp,code)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c11100218.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttackTarget()
		and (Duel.GetAttacker():IsControler(tp) and Duel.GetAttacker():IsRace(RACE_MACHINE)
			or Duel.GetAttackTarget():IsControler(tp) and Duel.GetAttackTarget():IsRace(RACE_MACHINE))
end
function c11100218.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=Duel.GetMatchingGroup(c11100218.atkfilter,tp,LOCATION_MZONE,0,nil,e)
	local tc=sg:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(c11100218.atkval)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		tc=sg:GetNext()
	end
end
function c11100218.atkfilter(c,e)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and not c:IsImmuneToEffect(e)
end
function c11100218.atkval(e,c)
	if c:IsType(TYPE_XYZ) then
		return c:GetRank()*300
	else
		return c:GetLevel()*300
	end
end