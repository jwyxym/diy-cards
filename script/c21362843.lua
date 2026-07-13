--欢愉之夜 弗米比罗姆·帕拉戴丝
function c21362843.initial_effect(c)
	c:EnableReviveLimit()
	--dr 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21362843,1))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION) 
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,21362843) 
	e1:SetCondition(c21362843.drcon)
	e1:SetTarget(c21362843.drtg)
	e1:SetOperation(c21362843.drop)
	c:RegisterEffect(e1) 
	--dd
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21362843,2))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O) 
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER) 
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,21362844) 
	e2:SetTarget(c21362843.ddtg)
	e2:SetOperation(c21362843.ddop)
	c:RegisterEffect(e2) 
	--
	local e3=Effect.CreateEffect(c) 
	e3:SetDescription(aux.Stringid(21362843,3))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O) 
	e3:SetCode(EVENT_DISCARD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,21362845) 
	e3:SetTarget(c21362843.tdtg)
	e3:SetOperation(c21362843.tdop)
	c:RegisterEffect(e3) 
end
function c21362843.drcon(e,tp,eg,ep,ev,re,r,rp) 
	local mg=e:GetHandler():GetMaterial()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) and mg:GetCount()>0 and mg:GetCount()==mg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA) 
end 
function c21362843.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(3)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,2)
end
function c21362843.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)==3 then
		Duel.ShuffleHand(p)
		Duel.BreakEffect()
		Duel.DiscardHand(p,nil,2,2,REASON_EFFECT+REASON_DISCARD)
	end
end
function c21362843.ddfil(c,dc) 
	return c:IsAttribute(dc:GetAttribute()) and c:IsFaceup() and aux.NegateEffectMonsterFilter(c) 
end 
function c21362843.tgfil(c,e,tp) 
	local g=Duel.GetMatchingGroup(c21362843.ddfil,tp,0,LOCATION_MZONE,nil,c)
	return c:IsDiscardable() and c:IsType(TYPE_MONSTER) and g:GetCount()>0 
end 
function c21362843.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21362843.tgfil,tp,LOCATION_HAND,0,1,nil,e,tp) end 
	local tc=Duel.SelectMatchingCard(tp,c21362843.tgfil,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst() 
	e:SetLabelObject(tc)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end
function c21362843.ddop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	local tc=e:GetLabelObject() 
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	local g=Duel.GetMatchingGroup(c21362843.ddfil,tp,0,LOCATION_MZONE,nil,tc)
	if g:GetCount()>0 then
		local tc=g:GetFirst() 
		while tc do 
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		Duel.AdjustInstantly()
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		tc=g:GetNext() 
		end 
		Duel.Destroy(g,REASON_EFFECT) 
	end
end
function c21362843.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) 
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end 
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end 
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil) 
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
function c21362843.tdop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	local tc=Duel.GetFirstTarget() 
	if tc:IsRelateToEffect(e) then 
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
	end 
end 


