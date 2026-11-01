--阿奎拉唱晓前的收纳
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
	--①B 破坏耐性
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(0)
	e2:SetCountLimit(1,id+40000)
	e2:SetTarget(s.btg)
	e2:SetOperation(s.bop)
	c:RegisterEffect(e2)
	--①C 回卡组抽3
	local e3=e1:Clone()
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
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
	local cc=e:GetHandler()
	local mg=Duel.GetMatchingGroup(s.cxmonster,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(mg) do s.regind(tc,cc) end
	local ce=Effect.CreateEffect(cc)
	ce:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ce:SetCode(EVENT_SPSUMMON_SUCCESS)
	ce:SetOperation(s.spop)
	ce:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ce,tp)
end
function s.cxmonster(c)
	return c:IsFaceup() and c:IsSetCard(0xe99) and c:IsType(TYPE_MONSTER)
end
function s.regind(tc,cc)
	if tc:GetFlagEffect(id)~=0 then return end
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	local e1=Effect.CreateEffect(cc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetProperty(EFFECT_FLAG_COUNT_LIMIT)
	e1:SetCountLimit(1)
	e1:SetValue(s.indval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end
function s.indval(e,re,r,rp)
	return 1
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.cxmonster,nil)
	if g:GetCount()==0 then return end
	local cc=e:GetHandler()
	for tc in aux.Next(g) do s.regind(tc,cc) end
end
--①C
function s.ctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.countcx(tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_EXTRA)>=9 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.cop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.gfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_EXTRA,0,9,9,nil)
	if g:GetCount()<9 then return end
	Duel.ConfirmCards(1-tp,g)
	eg=g:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
	if eg:GetCount()>0 then
		Duel.SendtoDeck(eg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	Duel.Draw(tp,3,REASON_EFFECT)
end
