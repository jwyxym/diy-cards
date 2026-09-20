--疯狂国度的噩梦之旅
function c19991013.initial_effect(c)
	--change code
	aux.EnableChangeCode(c,19991003,LOCATION_SZONE+LOCATION_GRAVE)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetCountLimit(1,19991013+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c19991013.target)
	e1:SetOperation(c19991013.activate)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19991013,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE+LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetTarget(c19991013.destg)
	e2:SetOperation(c19991013.desop)
	c:RegisterEffect(e2)
end
function c19991013.filter(c,ft)
	return c:IsCode(19991003) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
		and (ft==nil or ft>0 or c:IsType(TYPE_FIELD))
end
function c19991013.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=ft-1 end
		return Duel.IsExistingMatchingCard(c19991013.filter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,ft)
	end
end
function c19991013.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,c19991013.filter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil):GetFirst()
	if tc then
		Duel.SSet(tp,tc)
	end
end
function c19991013.cfilter(c)
	return c:IsCode(19991003) and c:IsFaceup()
end
function c19991013.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(c19991013.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,c19991013.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
function c19991013.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end