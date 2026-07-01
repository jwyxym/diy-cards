--墨染乐章 依靠
function c21301015.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,21301015+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c21301015.target)
	e1:SetOperation(c21301015.activate)
	c:RegisterEffect(e1) 
	--rme
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,21301016)
	e2:SetTarget(c21301015.rmetg)
	e2:SetOperation(c21301015.rmeop)
	c:RegisterEffect(e2)
	c21301015.remove_effect=e2	
end 
function c21301015.tgfil(c) 
	return c:IsFaceup() and c:IsSetCard(0x682) 
end 
function c21301015.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c21301015.tgfil(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c21301015.tgfil,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c21301015.tgfil,tp,LOCATION_MZONE,0,1,1,nil)
end
function c21301015.activate(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(function(e,re)
		return e:GetHandler()~=re:GetOwner() end)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CHAIN)
		tc:RegisterEffect(e1)
		if Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsSetCard(0x682) and c:IsType(TYPE_XYZ) end,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(21301015,0)) then
			Duel.BreakEffect() 
			local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil) 
			Duel.SendtoDeck(sg,nil,2,REASON_EFFECT) 
		end
	end
end
function c21301015.tdfil(c) 
	return c:IsFaceup() and c:IsSetCard(0x682) and c:IsAbleToDeck()  
end 
function c21301015.tdgck(g,e) 
	return g:IsContains(e:GetHandler())  
end 
function c21301015.rmetg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local g=Duel.GetMatchingGroup(c21301015.tdfil,tp,LOCATION_REMOVED,0,nil)
	if chk==0 then return g:CheckSubGroup(c21301015.tdgck,3,3,e) and Duel.IsPlayerCanDraw(tp) end 
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1) 
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_REMOVED)
end
function c21301015.rmeop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	local g=Duel.GetMatchingGroup(c21301015.tdfil,tp,LOCATION_REMOVED,0,nil) 
	if g:CheckSubGroup(c21301015.tdgck,3,3,e) then 
		local sg=g:SelectSubGroup(tp,c21301015.tdgck,false,3,3,e) 
		if Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)~=0 then 
			Duel.Draw(tp,1,REASON_EFFECT)
		end 
	end 
end 


