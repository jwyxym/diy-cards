--梭巡游侠选择取证
function c16820065.initial_effect(c)
	--draw
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,16820065+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c16820065.tgtg)
	e1:SetOperation(c16820065.tgop)
	c:RegisterEffect(e1)
	--set
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_END_PHASE)
	e2:SetCost(c16820065.setcost)
	e2:SetTarget(c16820065.settg)
	e2:SetOperation(c16820065.setop)
	c:RegisterEffect(e2)
end
function c16820065.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
		return g:CheckSubGroup(c16820065.gselect,2,2)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,2,tp,LOCATION_MZONE)
end
function c16820065.gselect(g)
	return g:IsExists(aux.AND(Card.IsSetCard,Card.IsFaceup),1,nil,0xdf28)
end
function c16820065.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	if #g>=2 and g:CheckSubGroup(c16820065.gselect,2,2) then
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOGRAVE)
		local g1=g:SelectSubGroup(tp,c16820065.gselect,false,2,2)
		if g1 and g1:GetCount()==2 then
			Duel.SendtoGrave(g1,0x40)
		end
	end
end
function c16820065.costfilter(c)
	return c:IsType(0x1) and c:IsSetCard(0xdf28) and c:IsAbleToRemoveAsCost()
end
function c16820065.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(c16820065.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c16820065.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c16820065.setfilter(c)
	return c:IsCode(16820050) and c:IsSSetable()
end
function c16820065.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c16820065.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c16820065.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,c16820065.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SSet(tp,g)
	end
end