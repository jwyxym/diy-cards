--存身的红龙
function c31280322.initial_effect(c)
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--回收抽卡 
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,31280322)
	e2:SetTarget(c31280322.target)
	e2:SetOperation(c31280322.operation)
	c:RegisterEffect(e2)
	--回复抽卡    
    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c31280322.condition1)
    e3:SetTarget(c31280322.target1)
	e3:SetOperation(c31280322.operation1)
	c:RegisterEffect(e3)
end	
function c31280322.tdfilter(c)
	return c:IsSetCard(0xca3) and c:IsType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and not c:IsCode(31280322) and c:IsAbleToDeck() and c:IsFaceupEx()
end
function c31280322.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c31280322.tdfilter(chkc) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingTarget(c31280322.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c31280322.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c31280322.operation(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetTargetsRelateToChain()
	if #sg==0 then return end
	aux.PlaceCardsOnDeckBottom(tp,sg)
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function c31280322.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsFaceup() and c:IsSetCard(0xca3) and c:IsPreviousLocation(LOCATION_GRAVE)
end
function c31280322.condition1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31280322.cfilter,1,nil,tp)
end
function c31280322.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end

function c31280322.setfilter1(c)
	return c:IsPublic() and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_RITUAL)
end
function c31280322.setfilter2(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceup()
end
function c31280322.operation1(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Recover(p,d,REASON_EFFECT)~=0 
    	and (Duel.IsExistingMatchingCard(c31280322.setfilter1,tp,LOCATION_HAND,0,1,nil)
        or Duel.IsExistingMatchingCard(c31280322.setfilter2,tp,LOCATION_MZONE,0,1,nil))
    	and Duel.IsPlayerCanDraw(tp,1)
        and Duel.SelectYesNo(tp,aux.Stringid(31280322,0)) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
    end    
end