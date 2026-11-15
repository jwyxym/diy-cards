--黄金项链
local s,id,o=GetID()
function s.initial_effect(c)
	--①：检索「篡夺」卡，并无效破坏「篡夺」卡的效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
--①：卡组「篡夺」卡
function s.thfilter(c)
	return c:IsSetCard(0x570) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	e:SetLabel(Duel.GetCurrentChain())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
--①：上一条连锁的目标卡里有「篡夺」卡
function s.negfilter(c)
	return c:IsSetCard(0x570)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	local cc=e:GetLabel()
	if not cc or cc<=1 then return end
	local te,tg=Duel.GetChainInfo(cc-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TARGET_CARDS)
	if not te or te:GetHandlerPlayer()~=1-tp then return end
	if bit.band(te:GetCategory(),CATEGORY_DESTROY)==0 then return end
	if not tg or not tg:IsExists(s.negfilter,1,nil) then return end
	if not Duel.IsChainDisablable(cc-1) then return end
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.NegateEffect(cc-1)
	end
end
