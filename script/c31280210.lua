--泰拉饭 D32钢锅黄金萝卜大餐
function c31280210.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--change cost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(31280208)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,31280210)
	c:RegisterEffect(e1)
	--atk 
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION) 
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,11280210)  
	e2:SetTarget(c31280210.xxtg)
	e2:SetOperation(c31280210.xxop)
	c:RegisterEffect(e2)
end
c31280210.SetCard_TnT_TLmeal=true 
function c31280210.xtgfil(c) 
	return c:IsFaceup() and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsSetCard(0xca0)) 
end 
function c31280210.xxtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(c31280210.xtgfil,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsAbleToDeck() and Duel.IsPlayerCanDraw(tp) end 
	Duel.SelectTarget(tp,c31280210.xtgfil,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)  
end
function c31280210.xxop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	if not (c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,2,REASON_EFFECT)~=0) then return end 
	local tc=Duel.GetFirstTarget() 
	if tc:IsFaceup() then   
		local x=math.floor(tc:GetLevel()/2)
		Duel.Draw(tp,x,REASON_EFFECT) 
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_HAND,0,nil)
		if g:GetCount()<x then return end
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=g:Select(tp,3,3,nil)
		aux.PlaceCardsOnDeckBottom(tp,sg)	 
	end 
end 


