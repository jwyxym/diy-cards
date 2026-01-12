--主·宰·者 混沌无序之存在
function c19000097.initial_effect(c)
	c:SetUniqueOnField(1,0,19000097)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,c19000097.mfilter,nil,2,99)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c19000097.atkval)
	c:RegisterEffect(e1)
	--material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19000097,2))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c19000097.mttg)
	e2:SetOperation(c19000097.mtop)
	c:RegisterEffect(e2)
	--negate
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetDescription(aux.Stringid(19000097,0))
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c19000097.negcon)
	e3:SetCost(c19000097.negcost1)
	e3:SetTarget(c19000097.negtg)
	e3:SetOperation(c19000097.negop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetDescription(aux.Stringid(19000097,1))
	e4:SetCost(c19000097.negcost2)
	c:RegisterEffect(e4)
	if not c19000097.global_check then
		c19000097.global_check=true
		c19000097[0]=nil
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PAY_LPCOST)
		ge1:SetOperation(c19000097.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function c19000097.mfilter(c,xyzc)
	return c:IsXyzLevel(xyzc,9) or (c:IsType(TYPE_XYZ) and c:IsRank(9))
end
function c19000097.atkval(e,c)
	return c:GetOverlayCount()*530
end
function c19000097.checkop(e,tp,eg,ep,ev,re,r,rp)
	local cid=Duel.GetCurrentChain()
	if cid>0 then
		c19000097[0]=Duel.GetChainInfo(cid,CHAININFO_CHAIN_ID)
	end
end
function c19000097.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)==c19000097[0]
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function c19000097.negcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1930) end
	Duel.PayLPCost(tp,1930)
end
function c19000097.negcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,3,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,3,3,REASON_COST)
end
function c19000097.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c19000097.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function c19000097.mtfilter(c,e)
	return c:IsCanOverlay()
end
function c19000097.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(c19000097.mtfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,LOCATION_REMOVED+LOCATION_GRAVE,1,nil) end
end
function c19000097.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,c19000097.mtfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,LOCATION_REMOVED+LOCATION_GRAVE,1,1,nil,e)
	if g:GetCount()>0 then
		Duel.Overlay(c,g)
	end
end
