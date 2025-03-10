--泰拉饭 萨米特色驱邪角兽肉串
function c31280211.initial_effect(c)
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
	e1:SetCountLimit(1,31280211)
	c:RegisterEffect(e1)
	--atk 
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION) 
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,11280211)  
	e2:SetTarget(c31280211.xxtg)
	e2:SetOperation(c31280211.xxop)
	c:RegisterEffect(e2)
end
c31280211.SetCard_TnT_TLmeal=true 
function c31280211.xtgfil(c) 
	return c:IsFaceup() and (c:IsAttribute(ATTRIBUTE_DARK) or c:IsSetCard(0xca0)) 
end 
function c31280211.xxtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(c31280211.xtgfil,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsAbleToDeck() and Duel.IsPlayerCanDraw(tp) and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 end 
	Duel.SelectTarget(tp,c31280211.xtgfil,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)  
end
function c31280211.xxop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	if not (c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,2,REASON_EFFECT)~=0) then return end 
	local tc=Duel.GetFirstTarget() 
	if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0 then   
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
		local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
		local nseq=math.log(s,2)
		Duel.MoveSequence(tc,nseq)   
		if c:GetSequence()==seq then
			local g=c:GetColumnGroup():Filter(Card.IsLocation,nil,LOCATION_MZONE)
			if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(31280211,0)) then
				local sg=g:Select(tp,1,1,nil)
				Duel.BreakEffect()
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end 
end 

