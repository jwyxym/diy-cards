--红血后 吸血鬼
function c11771405.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,c11771405.synfilter,aux.NonTuner(c11771405.synfilter),1)
	c:EnableReviveLimit()
	-- 无效并破坏
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11771405,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,11771405)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCost(c11771405.cost1)
	e1:SetTarget(c11771405.tg1)
	e1:SetOperation(c11771405.op1)
	c:RegisterEffect(e1)
	-- 特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11771405,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,11771406)
	e2:SetCondition(c11771405.con2)
	e2:SetTarget(c11771405.tg2)
	e2:SetOperation(c11771405.op2)
	c:RegisterEffect(e2)
end
--synchro summon
function c11771405.synfilter(c)
	return c:IsRace(RACE_ZOMBIE)
end
-- 1
function c11771405.costfilter1(c)
	return c:IsRace(RACE_ZOMBIE)
end
function c11771405.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,c11771405.costfilter1,1,REASON_COST,true,e:GetHandler(),tp) end
	local g=Duel.SelectReleaseGroupEx(tp,c11771405.costfilter1,1,1,REASON_COST,true,e:GetHandler(),tp)
	Duel.Release(g,REASON_COST)
end
function c11771405.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tg=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
function c11771405.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 2
function c11771405.cfilter2(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsReason(REASON_EFFECT)
end
function c11771405.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c11771405.cfilter2,1,nil,tp)
end
function c11771405.filter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c11771405.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c11771405.filter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function c11771405.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c11771405.filter2),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
