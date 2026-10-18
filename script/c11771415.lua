--吸血鬼少女
function c11771415.initial_effect(c)
	-- 盖放魔陷
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11771415,0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,11771415)
    e1:SetCost(c11771415.cost1)
	e1:SetTarget(c11771415.tg1)
	e1:SetOperation(c11771415.op1)
	c:RegisterEffect(e1)
    -- 特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11771415,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,11771416)
	e2:SetCondition(c11771415.con2)
	e2:SetTarget(c11771415.tg2)
	e2:SetOperation(c11771415.op2)
	c:RegisterEffect(e2)
end
-- 1
function c11771415.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function c11771415.filter1(c)
	return c:IsSetCard(0x8e) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function c11771415.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11771415.filter1,tp,LOCATION_DECK,0,1,nil) end
end
function c11771415.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,c11771415.filter1,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.SSet(tp,tc)
	end
end
-- 2
function c11771415.filter2(c,tp)
	return c:IsSummonLocation(LOCATION_GRAVE)
end
function c11771415.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c11771415.filter2,1,nil,tp)
end
function c11771415.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c11771415.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
