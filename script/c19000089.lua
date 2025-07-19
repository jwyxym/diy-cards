--向邪魔宣战
function c19000089.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19000089,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMINGS_CHECK_MONSTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c19000089.cost)
	e1:SetTarget(c19000089.target)
	e1:SetOperation(c19000089.activate)
	c:RegisterEffect(e1)
	--material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19000089,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c19000089.mattg)
	e2:SetOperation(c19000089.matop)
	c:RegisterEffect(e2)
end
function c19000089.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_COST) end
	Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_COST)
end
function c19000089.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c19000089.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function c19000089.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function c19000089.matfilter(c)
	return (c:IsCode(19000088) or c:IsLevel(9) or c:IsRank(9)) and c:IsCanOverlay()
end
function c19000089.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c19000089.xyzfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c19000089.xyzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(c19000089.matfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c19000089.xyzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function c19000089.matop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,c19000089.matfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.Overlay(tc,g)
		end
	end
end
