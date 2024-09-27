--杜丝娜瑞尔之化形
local m=11110012
local cm=_G["c"..m]
function c11110012.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,m)
	e1:SetTarget(cm.cost)
	e1:SetOperation(cm.thop)
	c:RegisterEffect(e1) 

end
function cm.thfilter(c)
	return c:IsSetCard(0xa61) and c:IsType(TYPE_MONSTER)
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
local g=Duel.GetMatchingGroup(cm.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then   
		
		return #g>=3
	end
	local sg=Duel.SelectMatchingCard(tp,cm.thfilter,tp,LOCATION_DECK,0,3,3,nil)
		Duel.ConfirmCards(1-tp,sg)
	Group.KeepAlive(sg)
	e:SetLabelObject(sg)
	
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
Duel.DisableShuffleCheck()
	local c=e:GetHandler()
	local sg=e:GetLabelObject()
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local tg1=Group.Select(sg,1-tp,1,1,nil)
		Duel.SendtoGrave(tg1,REASON_EFFECT)
sg:Sub(tg1)
Duel.MoveSequence(sg:GetFirst(),SEQ_DECKTOP)
Duel.MoveSequence(sg:GetNext(),SEQ_DECKTOP)
Duel.DisableShuffleCheck()
	   Duel.SortDecktop(tp,tp,#sg)
	for i=1,#sg do
		local mg=Duel.GetDecktopGroup(tp,1)
		Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
	end
Duel.BreakEffect()
   local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_REPTILE)
   if g:GetClassCount(Card.GetCode)>=5 and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then 
   local bb=Duel.SelectMatchingCard(tp,Card.IsRace,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,RACE_REPTILE)
   Duel.SpecialSummon(bb,0,tp,tp,false,false,POS_FACEUP)
end
end


