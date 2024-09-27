--滓溟之阿斯德莉亚
function c21300508.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,21300508+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c21300508.spcon)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,21300509)
	e2:SetCondition(c21300508.con)
	e2:SetTarget(c21300508.tg)
	e2:SetOperation(c21300508.op)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,21300508)
	e3:SetCondition(c21300508.scon)
	e3:SetCost(c21300508.scost)
	e3:SetTarget(c21300508.stg)
	e3:SetOperation(c21300508.sop)
	c:RegisterEffect(e3)
end
function c21300508.spfilter(c)
	return c:IsSetCard(0x674) and c:IsFaceup()
end
function c21300508.spcon(e,c)
	if c==nil then return true end
	return Duel.IsExistingMatchingCard(c21300508.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function c21300508.scon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
function c21300508.scost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function c21300508.sfilter(c,e,tp)
	return c:IsSetCard(0x674) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c21300508.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21300508.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
end
function c21300508.sop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(c21300508.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) or Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c21300508.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
	Duel.BreakEffect()
	if Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(21300508,0)) then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tc=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
	if tc then Duel.Destroy(tc,REASON_EFFECT) end
	end
	end
	end
end
function c21300508.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousPosition(POS_FACEUP)
end
function c21300508.filter1(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c21300508.tg(e,tp,eg,ep,ev,re,r,rp,chk,chck)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and c21300508.filter1(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c21300508.filter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,c21300508.filter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1,LOCATION_ONFIELD)
end
function c21300508.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFirstTarget()
	if g and g:IsRelateToEffect(e) then
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end