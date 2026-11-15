--表里的现场验证
local s,id,o=GetID()
local SHEN=57330010

function s.initial_effect(c)
	aux.AddCodeList(c,SHEN)
	--①：从以下效果选择1个发动。这个回合自己把「神域的物证」的效果发动过的场合，可以选两方发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--②：把墓地的这张卡除外才能发动。从自己墓地·除外状态把3张有「神域的物证」的卡名记述的卡返回卡组。那之后，可以从卡组把1只「表里侦探·诺·莱芙」视为仪式召唤特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1000)
	e2:SetCost(s.cost2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--①
function s.setfilter(c)
	return (aux.IsCodeListed(c,SHEN) or c:IsCode(SHEN)) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
function s.listedfilter(c)
	return c:IsFaceup() and (aux.IsCodeListed(c,SHEN) or c:IsCode(SHEN))
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		local b2=Duel.IsExistingMatchingCard(s.listedfilter,tp,LOCATION_ONFIELD,0,1,nil)
			and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_MONSTER)
		return b1 or b2
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.listedfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_MONSTER)
	if not b1 and not b2 then return end
	local both=(b1 and b2 and Duel.GetFlagEffect(tp,SHEN)~=0)
	local op=0
	if b1 and b2 then
		if both then
			op=Duel.SelectOption(tp,aux.Stringid(id,8),aux.Stringid(id,9),aux.Stringid(id,10))
		else
			op=Duel.SelectOption(tp,aux.Stringid(id,8),aux.Stringid(id,9))
		end
	elseif b2 then
		op=1
	end
	if op==0 or op==2 then
		s.do_set(e,tp)
	end
	if op==1 or op==2 then
		if op==2 then Duel.BreakEffect() end
		s.do_des(e,tp)
	end
end
function s.do_set(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SSet(tp,g)
	end
end
function s.do_des(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,TYPE_MONSTER)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

--②
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.bfilter(c)
	return c:IsAbleToDeck()
		and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end
function s.lfilter2(c)
	--「神域的物证」自身也视为记述了自己的卡名
	return s.bfilter(c) and (aux.IsCodeListed(c,SHEN) or c:IsCode(SHEN))
end
function s.ritfilter(c,e,tp)
	return c:IsCode(57330040) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local pool=Duel.GetMatchingGroup(s.bfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		return pool:FilterCount(s.lfilter2,nil)>0 and pool:GetCount()>=3
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local pool=Duel.GetMatchingGroup(s.bfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if pool:GetCount()<3 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=pool:FilterSelect(tp,s.lfilter2,1,1,nil)
	if g1:GetCount()==0 then return end
	pool:Sub(g1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g2=pool:Select(tp,2,2,nil)
	if g2:GetCount()<2 then return end
	g1:Merge(g2)
	Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_DECK,0,1,nil,e,tp) then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,11)) then return end
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,s.ritfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=tg:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
