--
function c19990052.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--scale
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(19990052,0))
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCountLimit(1)
	e0:SetTarget(c19990052.target)
	e0:SetOperation(c19990052.operation)
	c:RegisterEffect(e0)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19990052,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,19990052)
	e1:SetCondition(c19990052.spcon)
	e1:SetTarget(c19990052.sptg)
	e1:SetOperation(c19990052.spop)
	c:RegisterEffect(e1)
	--non tuner
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_NONTUNER)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetValue(c19990052.tnval)
	c:RegisterEffect(e2)
end
function c19990052.scalefilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb29) and c:GetCurrentScale()~=9
end
function c19990052.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and c19990052.scalefilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c19990052.scalefilter,tp,LOCATION_PZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c19990052.scalefilter,tp,LOCATION_PZONE,0,1,1,nil)
end
function c19990052.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetValue(9)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		tc:RegisterEffect(e2)
	end
end
function c19990052.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function c19990052.cfilter(c)
	return c:IsAbleToRemove() and c:IsSetCard(0xb29,0xb30)
end
function c19990052.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(c19990052.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c19990052.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c19990052.cfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,aux.ExceptThisCard(e))
	if sg:GetCount()>0 and Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c19990052.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end