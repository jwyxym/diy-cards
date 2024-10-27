--腥红之女皇 伊莉莎白
function c31000303.initial_effect(c)
	c:EnableCounterPermit(0x312)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,c31000303.mfilter1,c31000303.mfilter2,true)
	--counter
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c31000303.ctcon)
	e1:SetTarget(c31000303.cttg)
	e1:SetOperation(c31000303.ctop)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c31000303.target)
	e2:SetValue(c31000303.indct)
	c:RegisterEffect(e2)
	--control
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e3:SetCountLimit(1,31000303)
	e3:SetCost(c31000303.ctrcost)
	e3:SetTarget(c31000303.ctrtg)
	e3:SetOperation(c31000303.ctrop)
	c:RegisterEffect(e3)
end
function c31000303.mfilter1(c)
	return c:IsFusionSetCard(0x312)
end
function c31000303.mfilter2(c)
	return c:IsFusionType(TYPE_FUSION) and c:IsFusionAttribute(ATTRIBUTE_DARK)
end
function c31000303.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function c31000303.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,0x312,1) end
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,0x312,1)
	g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,#g,0,0)
end
function c31000303.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,0x312,1)
	for tc in aux.Next(g) do
		if tc:IsCanAddCounter(0x312,1) then
			tc:AddCounter(0x312,1)
		end
	end
end
function c31000303.target(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
function c31000303.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end
function c31000303.ctrcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x312,3,REASON_COST) end
	Duel.RemoveCounter(tp,1,1,0x312,3,REASON_COST)
end
function c31000303.ctrfilter(c)
	return c:IsControlerCanBeChanged() and c:IsFaceup()
end
function c31000303.ctrtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c31000303.ctrfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c31000303.ctrfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,c31000303.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function c31000303.ctrop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp,PHASE_END,1)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(ATTRIBUTE_DARK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end