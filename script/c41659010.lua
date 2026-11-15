--菲洛米拉唱晓的缚歌
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--①：「唱晓」怪兽表侧加入额外卡组的场合，从以下效果选择1个发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_DECK)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.con)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
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
--本回合可以使用(未使用)的效果
function s.avail(e,tp)
	local ops={}
	if Duel.GetFlagEffect(tp,id+30000)==0
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) then
		ops[#ops+1]=0
	end
	if Duel.GetFlagEffect(tp,id+40000)==0 and s.countcx(tp,LOCATION_HAND+LOCATION_EXTRA)>=3 then
		ops[#ops+1]=1
	end
	if Duel.GetFlagEffect(tp,id+50000)==0 and s.countcx(tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_EXTRA)>=9 then
		ops[#ops+1]=2
	end
	return ops
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ops=s.avail(e,tp)
	if chk==0 then return #ops>0 end
	local op=ops[1]
	if #ops>1 then
		if #ops==2 then
			op=ops[Duel.SelectOption(tp,aux.Stringid(id,ops[1]),aux.Stringid(id,ops[2]))+1]
		else
			op=ops[Duel.SelectOption(tp,aux.Stringid(id,ops[1]),aux.Stringid(id,ops[2]),aux.Stringid(id,ops[3]))+1]
		end
	end
	e:SetLabel(op)
	if op==0 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	Duel.RegisterFlagEffect(tp,({id+30000,id+40000,id+50000})[op+1],RESET_PHASE+PHASE_END,0,1)
	if op==0 then
		s.aop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.bop(e,tp,eg,ep,ev,re,r,rp)
	else
		s.cop(e,tp,eg,ep,ev,re,r,rp)
	end
end
--①A
function s.aop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--①B
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
