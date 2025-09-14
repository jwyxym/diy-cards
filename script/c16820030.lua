--梭巡游侠 析取
function c16820030.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,nil,1,2)
	c:EnableReviveLimit()
	--xyz
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,16820030)
	e1:SetTarget(c16820030.ovtg)
	e1:SetOperation(c16820030.ovop)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,16820030+1)
	e2:SetCondition(c16820030.con)
	e2:SetCost(c16820030.cost)
	e2:SetTarget(c16820030.tg)
	e2:SetOperation(c16820030.op)
	c:RegisterEffect(e2)
	c16820030.discard_effect=e1
end
function c16820030.matfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRank(1)
end
function c16820030.ovfilter(c)
	return c:IsFacedown() and c:IsCanOverlay()
end
function c16820030.ovtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c16820030.matfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(c16820030.ovfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
end
function c16820030.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.IsExistingMatchingCard(c16820030.matfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		or not Duel.IsExistingMatchingCard(c16820030.ovfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
		return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,c16820030.matfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
	local sg=Duel.SelectMatchingCard(tp,c16820030.ovfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	local tc=sg:GetFirst()
	if tc then
		local sg=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			Duel.SendtoGrave(og,REASON_RULE)
		end
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
function c16820030.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function c16820030.cfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not (c:IsType(0x1) and c:IsSetCard(0xdf28) and c:IsAbleToRemoveAsCost()) then return end
	local te=c.discard_effect
	if not te then return false end
	local tg=te:GetTarget()
	return not tg or tg and tg(e,tp,eg,ep,ev,re,r,rp,0,nil,c)
end
function c16820030.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
		and Duel.IsExistingMatchingCard(c16820030.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c16820030.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
function c16820030.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetLabelObject()
	Duel.ClearTargetCard()
	local te=tc.discard_effect
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
end
function c16820030.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local te=tc.discard_effect
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end