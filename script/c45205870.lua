--望梅止渴
local s,id=GetID()
function s.initial_effect(c)
	--① 把自己卡组的1张卡展示才能发动。展示那张卡放置在自己卡组最上方。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

-- 卡组过滤：任意卡
function s.deckfilter(c)
	return true
end

-- cost：选卡组1张卡，移到卡组最上方，然后一次性展示（双方可见）
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.deckfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 then return end
	local tc=g:GetFirst()
	Duel.MoveSequence(tc,SEQ_DECKTOP)
	Duel.ConfirmCards(1-tp,Group.FromCards(tc))
	Duel.ConfirmCards(tp,Group.FromCards(tc))
end

-- target
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

-- operation：空
function s.op(e,tp,eg,ep,ev,re,r,rp)
end

return s
