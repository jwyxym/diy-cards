--天珠
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,48179391)
	
	--手卡发动条件：自己场上有「奥利哈刚之神」
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.handcon)
	c:RegisterEffect(e0)
	
	--①效果：自己场上有「山铜结界」，对方发动魔陷怪兽效果时，无效并破坏，那之后可以回收5张抽2
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	
	--②效果：墓地除外，检索1张山铜结界或记述卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

function s.handcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,45205530)
end

-- ①效果
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,48179391)
end

function s.orifilter(c)
	return c:IsCode(48179391) or aux.IsCodeListed(c,48179391)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsChainNegatable(ev) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		local g=Duel.GetMatchingGroup(s.orifilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		if #g>=5 and Duel.IsPlayerCanDraw(tp,2) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local sg=g:Select(tp,5,5,nil)
			if #sg>0 then
				Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
				Duel.ShuffleDeck(tp)
				Duel.BreakEffect()
				Duel.Draw(tp,2,REASON_EFFECT)
			end
		end
	end
end

-- ②效果
function s.thfilter(c)
	return (c:IsCode(48179391) or aux.IsCodeListed(c,48179391)) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

return s
