--刻界的启明者 埃忒尔
local s,id,o=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	aux.AddLinkProcedure(c,s.mat,1,1)
	c:EnableReviveLimit()
	--连接召唤成功
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--这张卡送去墓地
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.retcon)
	e2:SetTarget(s.rettg)
	e2:SetOperation(s.retop)
	c:RegisterEffect(e2)
end
function s.mat(c)
	return c:IsLinkSetCard(0x346a)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.tgfilter(c)
	return c:IsPublic() and c:IsAbleToGraveAsCost()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.thfilter1(c)
	return c:IsCode(12950134) and c:IsAbleToHand()
end
function s.thfilter2(c)
	return c:IsSetCard(0x346a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
		and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end

function s.actfilter(c,tp)
	return c:IsCode(12950134) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
	or not Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g2=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if #g1>0 and #g2>0 then
		g1:AddCard(g2:GetFirst())
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g1)
		if Duel.GetMatchingGroupCount(Card.IsPublic,tp,LOCATION_HAND,0,nil)>=2
		and Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_HAND,0,1,nil,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.actfilter),tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
			if tc then
				local field=tc:IsType(TYPE_FIELD)
				if field then
					local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
					if fc then
						Duel.SendtoGrave(fc,REASON_RULE)
						Duel.BreakEffect()
					end
					Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
				else
					Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
				end
				local te=tc:GetActivateEffect()
				te:UseCountLimit(tp,1,true)
				local tep=tc:GetControler()
				local cost=te:GetCost()
				if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
				if field then
					Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
				end
			end
		end
	end
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSummonType()==SUMMON_TYPE_LINK and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.retfilter(c)
	return c:IsSetCard(0x346a) and c:IsAbleToDeck() and not c:IsCode(id)
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.retfilter,tp,LOCATION_GRAVE,0,1,nil)
	and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.retfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		if Duel.SendtoDeck(g,nil,2,REASON_EFFECT)~=0 then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
