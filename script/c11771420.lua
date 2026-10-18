--吸血鬼尊王 弗德古拉
function c11771420.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_ZOMBIE),3,5,c11771420.lcheck)
	c:EnableReviveLimit()
	-- 生命归还 - 伤害触发
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11771420,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c11771420.con1)
	e1:SetOperation(c11771420.op1)
	c:RegisterEffect(e1)
	-- 生命归还 - 支付生命触发
	local e1a=e1:Clone()
	e1a:SetCode(EVENT_PAY_LPCOST)
	c:RegisterEffect(e1a)
	-- 特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11771420,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,11771420)
	e2:SetTarget(c11771420.tg2)
	e2:SetOperation(c11771420.op2)
	c:RegisterEffect(e2)
	-- 遗言苏生
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11771420,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCountLimit(1,11771421)
	e3:SetCondition(c11771420.con3)
	e3:SetOperation(c11771420.op3)
	c:RegisterEffect(e3)
end
--link summon
function c11771420.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x8e)
end
-- 1
function c11771420.con1(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function c11771420.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Recover(tp,1000,REASON_EFFECT)
end
-- 2
function c11771420.spfilter(c,e,tp)
	return c:IsSetCard(0x8e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c11771420.tgfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave()
end
function c11771420.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c11771420.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c11771420.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(c11771420.tgfilter,tp,LOCATION_HAND+LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c11771420.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_HAND+LOCATION_MZONE)
end
function c11771420.op2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,c11771420.tgfilter,tp,LOCATION_HAND+LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 3
function c11771420.con3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD) and bit.band(r,REASON_EFFECT)~=0
end
function c11771420.op3(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetCondition(c11771420.con33)
	e1:SetOperation(c11771420.op33)
	if Duel.GetCurrentPhase()<=PHASE_STANDBY then
		e1:SetReset(RESET_PHASE+PHASE_STANDBY,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_STANDBY)
	end
	Duel.RegisterEffect(e1,tp)
end
function c11771420.con33(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c11771420.spfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
end
function c11771420.spfilter2(c,e,tp)
	return c:IsCode(11771420) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c11771420.op33(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,11771420)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c11771420.spfilter2),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
