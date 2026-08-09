--
function c19993033.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,c19993033.mfilter,4,2)
	c:EnableReviveLimit()
	--set trap from deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19993033,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,19993033)
	e2:SetTarget(c19993033.settg)
	e2:SetOperation(c19993033.setop)
	c:RegisterEffect(e2)
	c19993033.sps_effect=e2
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19993033,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,19993033+100)
	e3:SetCost(c19993033.descost)
	e3:SetTarget(c19993033.destg)
	e3:SetOperation(c19993033.desop)
	c:RegisterEffect(e3)
end
function c19993033.mfilter(c)
	return c:IsSetCard(0xb35) and c:IsLevel(4)
end
function c19993033.setfilter(c)
	return c:IsSetCard(0xb35) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function c19993033.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19993033.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c19993033.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,c19993033.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
function c19993033.costfilter(c)
	return c:IsCode(19993005) or c:IsCode(19993021) or c:IsCode(19993030)
end
function c19993033.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c19993033.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=Duel.GetMatchingGroupCount(c19993033.costfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return ct>0 and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	local max=math.min(ct,Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,max,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function c19993033.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
