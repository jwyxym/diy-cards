--临终之刻的魔姬奥义
function c51600211.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,51600211)
	e1:SetCondition(c51600211.effcon)
	e1:SetTarget(c51600211.efftg)
	e1:SetOperation(c51600211.effop)
	c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,51600211)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c51600211.sptg)
	e2:SetOperation(c51600211.spop)
	c:RegisterEffect(e2)
end



function c51600211.filter(c)
return c:IsSetCard(0x910) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_FUSION)
end
function c51600211.filter2(c)
return c:IsSetCard(0x910) and not c:IsCode(51600211)
end
function c51600211.effcon(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function c51600211.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c51600211.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
function c51600211.effop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,c51600211.filter,tp,LOCATION_ONFIELD,0,1,1,nil):GetFirst()
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(g,REASON_EFFECT)>0 then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end



function c51600211.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and chkc:IsSetCard(0x910) end
	if chk==0 then return Duel.IsExistingTarget(c51600211.filter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c51600211.filter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
function c51600211.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
