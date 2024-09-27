--炽神界的神官
local cm,m,o=GetID()
function cm.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FAIRY),6,3,nil,nil,3)
	c:EnableReviveLimit()
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,m+4)
	e2:SetCost(cm.cost)
	e2:SetCondition(cm.con)
	e2:SetTarget(cm.tg)
	e2:SetOperation(cm.op)
	c:RegisterEffect(e2)
	--cannot target
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local sg=e:GetHandler():GetOverlayGroup():Select(tp,1,1,nil)
	if not sg then return end
	Duel.SendtoGrave(sg,REASON_COST)
	sg:KeepAlive()
	e:SetLabelObject(sg)
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev) and re:GetHandler():IsLocation(LOCATION_MZONE)
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local sg=e:GetLabelObject():GetFirst()
	if sg:GetOriginalType()&TYPE_MONSTER>0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,re:GetHandler(),1,0,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,re:GetHandler(),1,0,0)
	end
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=e:GetLabelObject():GetFirst()
	if Duel.NegateActivation(ev) then
		if sg:GetOriginalType()&TYPE_MONSTER>0 and re:GetHandler():IsRelateToEffect(re) then
			Duel.BreakEffect()
			Duel.Destroy(re:GetHandler(),REASON_EFFECT)
		elseif sg:GetOriginalType()&TYPE_MONSTER==0 and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE
			and re:GetHandler():IsRelateToEffect(re) and not re:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then
			Duel.BreakEffect()
			Duel.GetControl(re:GetHandler(),tp,PHASE_END,1)
		end
	end
end
