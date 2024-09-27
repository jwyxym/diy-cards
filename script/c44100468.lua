--诺艾尔 帝姬武装
function c44100468.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcMix(c,false,true,c44100468.fusfilter1,c44100468.fusfilter2,c44100468.fusfilter3,c44100468.fusfilter4)
	aux.EnablePendulumAttribute(c,false)
	--pzone specialsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44100468,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,44100468)
	e1:SetCost(c44100468.spcost)
	e1:SetTarget(c44100468.sptg)
	e1:SetOperation(c44100468.spop)
	c:RegisterEffect(e1)
	--atkup
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44100468,2))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c44100468.atkcon)
	e2:SetOperation(c44100468.atkop)
	c:RegisterEffect(e2)
	--Immune
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	--immune spell
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c44100468.efilter)
	c:RegisterEffect(e4)
	--atkup2
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(44100468,3))
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c44100468.defcon)
	e5:SetCost(c44100468.defcost)
	e5:SetOperation(c44100468.defop)
	c:RegisterEffect(e5)
	--pendulum move
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(44100468,4))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCondition(c44100468.pencon)
	e6:SetTarget(c44100468.pentg)
	e6:SetOperation(c44100468.penop)
	c:RegisterEffect(e6)
	--spsummon condition
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e7:SetCode(EFFECT_SPSUMMON_CONDITION)
	e7:SetValue(c44100468.fsplimit)
	c:RegisterEffect(e7)
end
c44100468.material_type=TYPE_SYNCHRO
function c44100468.fusfilter1(c)
	return c:IsSetCard(0x44a) and c:IsFusionType(TYPE_SYNCHRO) and c:IsLevelAbove(8)
end
function c44100468.fusfilter2(c)
	return c:IsSetCard(0x44a) and c:IsFusionType(TYPE_XYZ) and c:IsRankAbove(8)
end
function c44100468.fusfilter3(c)
	return c:IsSetCard(0x44a)
end
function c44100468.fusfilter4(c)
	return c:IsSetCard(0x44a)
end
function c44100468.costfilter(c)
	return c:IsSetCard(0x44a) and c:IsType(TYPE_MONSTER) and (c:IsControler(tp) or c:IsFaceup())
end
function c44100468.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetReleaseGroup(tp):Filter(c44100468.costfilter,nil,tp)
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	aux.UseExtraReleaseCount(g,tp)
	Duel.Release(g,REASON_COST)
end
function c44100468.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c44100468.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(44100468,1))
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_DAMAGE_STEP_END)
		e1:SetCountLimit(1,44110468)
		e1:SetCondition(c44100468.atcon)
		e1:SetCost(c44100468.atcost)
		e1:SetOperation(c44100468.atop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
function c44100468.atcostfilter(c)
	return c:IsSetCard(0x44a) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function c44100468.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetAttacker()==c and c:IsChainAttackable(0)
end
function c44100468.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c44100468.atcostfilter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c44100468.atcostfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
function c44100468.atop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChainAttack()
end
function c44100468.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function c44100468.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c:GetBaseDefense())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
	c:RegisterEffect(e1)
end
function c44100468.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function c44100468.defcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsControler(1-tp) and bc:IsFaceup() and bc:GetDefense()>0
end
function c44100468.defcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(44100468)==0 end
	c:RegisterFlagEffect(44100468,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
function c44100468.defop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsRelateToBattle() and c:IsFaceup() and bc:IsRelateToBattle() and bc:IsFaceup() and bc:IsControler(1-tp) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(bc:GetDefense())
		c:RegisterEffect(e1)
	end
end
function c44100468.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
function c44100468.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function c44100468.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function c44100468.fsplimit(e,se,sp,st)
	return se:GetHandler():IsCode(44100467) or se:GetHandler():IsCode(44100477) or se:GetHandler():IsCode(44100468)
end
