--
function c19990044.initial_effect(c)
	c:SetSPSummonOnce(19990044)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,c19990044.ffilter,2,true)
	--pendulum summon
	aux.EnablePendulumAttribute(c,false)
	--cannot remove
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetTarget(c19990044.rmlimit)
	e1:SetCondition(c19990044.imcon)
	c:RegisterEffect(e1)
	--pendulum
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19990044,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(c19990044.pencon)
	e2:SetTarget(c19990044.pentg)
	e2:SetOperation(c19990044.penop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19990044,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,19990044)
	e3:SetCost(c19990044.spcost)
	e3:SetTarget(c19990044.sptg)
	e3:SetOperation(c19990044.spop)
	c:RegisterEffect(e3)
end
function c19990044.ffilter(c)
	return c:IsFusionSetCard(0xb30) or c:IsFusionSetCard(0xb29)
end
function c19990044.rmlimit(e,c,p)
	return c:IsLocation(LOCATION_GRAVE+LOCATION_HAND)
end
function c19990044.imcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function c19990044.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE)
end
function c19990044.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function c19990044.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function c19990044.spsfilter(c,tp)
	return c:IsSetCard(0xb29) and Duel.GetMZoneCount(tp,c)>0
end
function c19990044.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,c19990044.spsfilter,2,REASON_COST,true,e,tp) end
	local g=Duel.SelectReleaseGroupEx(tp,c19990044.spsfilter,2,2,REASON_COST,true,e,tp)
	Duel.Release(g,REASON_COST)
end
function c19990044.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c19990044.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
