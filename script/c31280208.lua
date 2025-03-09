--泰拉饭 鲍勃农场源石虫餐
function c31280208.initial_effect(c)
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
	e1:SetCountLimit(1,31280208)
	c:RegisterEffect(e1)
	--atk 
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION) 
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,11280208)  
	e2:SetTarget(c31280208.xxtg)
	e2:SetOperation(c31280208.xxop)
	c:RegisterEffect(e2)
end
c31280208.SetCard_TnT_TLmeal=true 
function c31280208.xtgfil(c) 
	return c:IsFaceup() and (c:IsRace(RACE_REPTILE+RACE_INSECT) or c:IsSetCard(0x3a21)) 
end 
function c31280208.xxtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(c31280208.xtgfil,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsAbleToDeck() and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end 
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)  
end
function c31280208.xxop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	if not (c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,2,REASON_EFFECT)~=0) then return end 
	local tc=Duel.GetFirstTarget()
	local sc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if sc then   
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK) 
		e1:SetRange(LOCATION_SZONE)
		e1:SetValue(tc:GetBaseAttack()) 
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
	end 
end 





