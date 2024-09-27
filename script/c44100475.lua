--诺艾尔 心铠武装
function c44100475.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcMix(c,false,true,c44100475.fusfilter1,c44100475.fusfilter2,c44100475.fusfilter3,c44100475.fusfilter4)
	aux.EnablePendulumAttribute(c,false)
	--pzone specialsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44100475,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,44100475)
	e1:SetCost(c44100475.spcost)
	e1:SetTarget(c44100475.sptg)
	e1:SetOperation(c44100475.spop)
	c:RegisterEffect(e1)
	--to deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44100475,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,44100475)
	e2:SetCost(c44100475.tdcost)
	e2:SetTarget(c44100475.tdtg)
	e2:SetOperation(c44100475.tdop)
	c:RegisterEffect(e2)
	--spsummon condition
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(c44100475.fsplimit)
	c:RegisterEffect(e3)
	--must attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_MUST_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e5:SetValue(c44100475.atklimit)
	c:RegisterEffect(e5)
	--Immune
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetValue(aux.tgoval)
	c:RegisterEffect(e6)
	--immune spell
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_IMMUNE_EFFECT)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetValue(c44100475.efilter)
	c:RegisterEffect(e7)
	--def up
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(44100475,2))
	e8:SetCategory(CATEGORY_DEFCHANGE)
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1,44110475)
	e8:SetCondition(c44100475.defcon)
	e8:SetOperation(c44100475.defop)
	c:RegisterEffect(e8)
	--pendulum move
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(44100475,3))
	e9:SetCategory(CATEGORY_DAMAGE)
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e9:SetCode(EVENT_LEAVE_FIELD)
	e9:SetProperty(EFFECT_FLAG_DELAY)
	e9:SetCountLimit(1,44120475)
	e9:SetCondition(c44100475.damcon)
	e9:SetTarget(c44100475.damtg)
	e9:SetOperation(c44100475.damop)
	c:RegisterEffect(e9)
end
c44100475.material_type=TYPE_SYNCHRO
function c44100475.fusfilter1(c)
	return c:IsSetCard(0x44a) and c:IsFusionType(TYPE_SYNCHRO) and c:IsLevelAbove(8)
end
function c44100475.fusfilter2(c)
	return c:IsSetCard(0x44a) and c:IsFusionType(TYPE_XYZ) and c:IsRankAbove(8)
end
function c44100475.fusfilter3(c)
	return c:IsSetCard(0x44a)
end
function c44100475.fusfilter4(c)
	return c:IsSetCard(0x44a)
end
function c44100475.costfilter(c)
	return c:IsSetCard(0x44a) and c:IsType(TYPE_MONSTER) and (c:IsControler(tp) or c:IsFaceup())
end
function c44100475.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetReleaseGroup(tp):Filter(c44100475.costfilter,nil,tp)
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	aux.UseExtraReleaseCount(g,tp)
	Duel.Release(g,REASON_COST)
end
function c44100475.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c44100475.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c44100475.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c44100475.tdfilter(c)
	return c:IsSetCard(0x44a) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function c44100475.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c44100475.tdfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	local g=Duel.GetMatchingGroup(c44100475.tdfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
function c44100475.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c44100475.tdfilter,tp,LOCATION_GRAVE,0,nil)
	if aux.NecroValleyNegateCheck(g) then return end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function c44100475.fsplimit(e,se,sp,st)
	return se:GetHandler():IsCode(44100467) or se:GetHandler():IsCode(44100477) or se:GetHandler():IsCode(44100475)
end
function c44100475.atklimit(e,c)
	return c==e:GetHandler()
end
function c44100475.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function c44100475.defcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsControler(1-tp) and bc:IsFaceup() and bc:GetAttack()>0
end
function c44100475.defop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsRelateToBattle() and c:IsFaceup() and bc:IsRelateToBattle() and bc:IsFaceup() and bc:IsControler(1-tp) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(bc:GetAttack()/2)
		c:RegisterEffect(e1)
	end
end
function c44100475.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
function c44100475.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(2000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end
function c44100475.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
