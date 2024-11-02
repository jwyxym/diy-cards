--赤影杀灭阵
function c51200155.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,51200155+EFFECT_COUNT_CODE_OATH)
	e0:SetOperation(c51200155.act)
	c:RegisterEffect(e0)
	--破坏抗性
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(c51200155.con)
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	--回收抽卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51200155,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,51200155)
	e2:SetTarget(c51200155.sptg)
	e2:SetOperation(c51200155.spop)
	c:RegisterEffect(e2)
	--盖放魔陷
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51200156,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,51200156)
	e3:SetCondition(c51200155.condition)
	e3:SetCost(c51200155.cost)
	e3:SetTarget(c51200155.target)
	e3:SetOperation(c51200155.activate)
	c:RegisterEffect(e3)
end
	function c51200155.thfilter(c)
	return c:IsCode(51200100)
		and c:IsAbleToHand()
end
	function c51200155.act(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c51200155.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(51200155,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
	function c51200155.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x65d) and c:GetOriginalType()&TYPE_MONSTER~=0
end
	function c51200155.con(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(c51200155.confilter,tp,LOCATION_ONFIELD,0,1,nil)
end
	function c51200155.filter(c)
	return c:IsSetCard(0x65d)
end
	function c51200155.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and chkc:IsSetCard(0x65d) end
	if chk==0 then return Duel.IsExistingTarget(c51200155.filter,tp,LOCATION_REMOVED,0,2,nil)
		end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c51200155.filter,tp,LOCATION_REMOVED,0,2,4,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
	function c51200155.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(51200155,0)) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
	function c51200155.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c51200155.filter,tp,LOCATION_GRAVE,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c51200155.filter,tp,LOCATION_GRAVE,0,3,3,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
	function c51200155.condition(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:IsSetCard(0x65d) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
	function c51200155.setfilter(c,rc)
	return c:IsSetCard(0x65d) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
	function c51200155.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c51200155.setfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:GetCount()>0 end
end
	function c51200155.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c51200155.setfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local dc=g:Select(tp,1,1,nil):GetFirst()
		if Duel.SSet(tp,dc,tp,true)>0 then
			if dc:IsType(TYPE_QUICKPLAY) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				dc:RegisterEffect(e1)
			end
		end
	end
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetTargetRange(1,0)
	e2:SetValue(c51200155.aclimit)
	Duel.RegisterEffect(e2,tp)
end
	function c51200155.aclimit(e,re,tp)
	return not re:GetHandler():IsCode(51200155) and re:IsActiveType(TYPE_TRAP)
end