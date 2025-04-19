--拉芙希妮·深池，“焰影”
function c31280302.initial_effect(c)
	aux.AddCodeList(c,31280323)
	c:EnableReviveLimit()
	--卡片破坏
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(31280302,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCountLimit(1,31280302)
	e1:SetCondition(c31280302.condition)
	e1:SetTarget(c31280302.target)
	e1:SetOperation(c31280302.operation)
	c:RegisterEffect(e1)
	--墓地特召    
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(31280302,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e2:SetCountLimit(1,31380302)
	e2:SetCondition(c31280302.condition1)
	e2:SetTarget(c31280302.target1)
	e2:SetOperation(c31280302.operation1)
	c:RegisterEffect(e2)
	--怪兽破坏
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(31280302,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c31280302.condition2)
	e3:SetTarget(c31280302.target2)
	e3:SetOperation(c31280302.operation2)
	c:RegisterEffect(e3)    
end
function c31280302.filter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(1-tp) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function c31280302.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(c31280302.filter,1,nil,tp) and ((c:IsPublic() and c:IsLocation(LOCATION_HAND)) or c:IsLocation(LOCATION_MZONE))
end
function c31280302.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c31280302.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function c31280302.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousControler(tp) and c:IsSetCard(0xca3) and c:IsReason(REASON_EFFECT)
end
function c31280302.condition1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31280302.cfilter,1,nil,tp)
end
function c31280302.spfilter(c,e,tp)
	return c:IsSetCard(0xca3) and not c:IsType(TYPE_RITUAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.DrytronSpSummonType(c))
end
function c31280302.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31280302.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsAbleToGrave()
		and Duel.IsExistingTarget(c31280302.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c31280302.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c31280302.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,aux.DrytronSpSummonType(tc),POS_FACEUP)~=0 then
			Duel.BreakEffect()
			Duel.Recover(tp,1000,REASON_EFFECT)
		end
	end
end
function c31280302.condition2(e,tp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
		and e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN)
end
function c31280302.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c31280302.operation2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end