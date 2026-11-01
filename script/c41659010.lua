--菲洛米拉唱晓的缚歌
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--①A 加手
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_DECK)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id+30000)
	e1:SetCondition(s.con)
	e1:SetTarget(s.atg)
	e1:SetOperation(s.aop)
	c:RegisterEffect(e1)
	--①B 解放·发动封锁
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(0)
	e2:SetCountLimit(1,id+40000)
	e2:SetTarget(s.btg)
	e2:SetOperation(s.bop)
	c:RegisterEffect(e2)
	--①C 除外并盖放
	local e3=e1:Clone()
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetCountLimit(1,id+50000)
	e3:SetTarget(s.ctg)
	e3:SetOperation(s.cop)
	c:RegisterEffect(e3)
end
function s.exfilter(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() and c:IsSetCard(0xe99) and c:IsType(TYPE_MONSTER)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.exfilter,1,nil)
end
function s.gfilter(c)
	return c:IsSetCard(0xe99) and (not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup())
end
function s.cxfilter(c)
	if c:IsLocation(LOCATION_EXTRA) then return c:IsFaceup() end
	return true
end
function s.thfilter(c)
	return c:IsSetCard(0xe99) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and s.cxfilter(c)
end
function s.countcx(tp,loc)
	local g=Duel.GetMatchingGroup(s.gfilter,tp,loc,0,nil)
	return g:GetCount()
end
--①A
function s.atg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.aop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--①B
function s.btg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.countcx(tp,LOCATION_HAND+LOCATION_EXTRA)>=3 end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.bop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.gfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,3,3,nil)
	if g:GetCount()<3 then return end
	Duel.ConfirmCards(1-tp,g)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UNRELEASABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xe99))
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetValue(s.aclimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.aclimit(e,re,tp)
	if not re:IsActiveType(TYPE_MONSTER) then return false end
	local cc=Duel.GetCurrentChain()
	if cc==0 then return false end
	for i=1,cc do
		local ce=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		if ce then
			local h=ce:GetHandler()
			if h and h:IsSetCard(0xe99) and h:IsControler(1-tp) and h:IsLocation(LOCATION_MZONE) then
				return true
			end
		end
	end
	return false
end
--①C
function s.ctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return s.countcx(tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_EXTRA)>=9
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.cop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.gfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_EXTRA,0,9,9,nil)
	if g:GetCount()<9 then return end
	Duel.ConfirmCards(1-tp,g)
	local og=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,1-tp,LOCATION_ONFIELD,0,nil)
	if og:GetCount()==0 then return end
	Duel.Remove(og,POS_FACEUP,REASON_EFFECT)
	local rg=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
	local mg=rg:Filter(Card.IsType,nil,TYPE_MONSTER)
	local sg=rg:Filter(aux.NOT(Card.IsType),nil,TYPE_MONSTER)
	for tc in aux.Next(mg) do
		if Duel.MoveToField(tc,1-tp,1-tp,LOCATION_MZONE,POS_FACEDOWN_DEFENSE,true) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
	if sg:GetCount()>0 then Duel.SSet(1-tp,sg) end
end
