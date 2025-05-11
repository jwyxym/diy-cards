--沉沦虚幻的龙神
function c21300003.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--SpecialSummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21300003,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O) 
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,21300003)
	e1:SetCondition(c21300003.spcon1)
	e1:SetTarget(c21300003.sptg)
	e1:SetOperation(c21300003.spop)
	c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21300003,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O) 
	e1:SetCode(EVENT_SSET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,21300003)
	e1:SetCondition(c21300003.spcon2)
	e1:SetTarget(c21300003.sptg)
	e1:SetOperation(c21300003.spop)
	c:RegisterEffect(e1) 
	--destroy
	local e2=Effect.CreateEffect(c)  
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET) 
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,11300003)
	e2:SetCost(c21300003.descost)
	e2:SetTarget(c21300003.destg)
	e2:SetOperation(c21300003.desop)
	c:RegisterEffect(e2)
end 
function c21300003.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function c21300003.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp 
end
function c21300003.sptg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local x=Duel.GetFieldGroupCount(tp,0,LOCATION_SZONE)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and x>0 and Duel.IsPlayerCanDraw(tp,x) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0) 
	Duel.SetOperationInfo(0,CATEGORY_DRAW,e:GetHandler(),1,0,0)
end
function c21300003.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local x=Duel.GetFieldGroupCount(tp,0,LOCATION_SZONE)
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and x>0 and Duel.IsPlayerCanDraw(tp,x) then
		Duel.BreakEffect() 
		Duel.Draw(tp,x,REASON_EFFECT) 
	end 
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS) 
	e1:SetCode(EVENT_PHASE+PHASE_END) 
	e1:SetCountLimit(1) 
	e1:SetCondition(c21300003.xtdcon) 
	e1:SetOperation(c21300003.xtdop) 
	e1:SetReset(RESET_PHASE+PHASE_END) 
	Duel.RegisterEffect(e1,tp) 
end
function c21300003.xtdcon(e,tp,eg,ep,ev,re,r,rp)  
	local x=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	return x>7 and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,x-7,nil) 
end 
function c21300003.xtdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local x=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	Duel.Hint(HINT_CARD,0,21300003)
	if x>7 and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,7-x,nil) then  
		Duel.Hint(HINT_CARD,0,21300003)
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,x-7,x-7,nil) 
		Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
	end 
end 
function c21300003.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function c21300003.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c21300003.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c21300003.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c21300003.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,c21300003.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c21300003.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end


