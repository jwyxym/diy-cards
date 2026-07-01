--哥布林召唤阵
--卡密ID: 45205509
--字段代码: 0xAC

local s,id=GetID()

function s.initial_effect(c)
	--永续陷阱发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	
	--①效果：自己·对方的回合，从以下效果选择1个使用
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE+CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end

--选择效果
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local b1 = Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil)
		local b2 = Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
		local b3 = Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_REMOVED,0,3,nil)
			and Duel.IsPlayerCanDraw(tp,1)
		return b1 or b2 or b3
	end
	
	local op=aux.SelectFromOptions(tp,
		{true,aux.Stringid(id,1)},
		{true,aux.Stringid(id,2)},
		{true,aux.Stringid(id,3)})
	e:SetLabel(op)
	
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	elseif op==2 then
		e:SetCategory(CATEGORY_REMOVE)
		s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	elseif op==3 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
		s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		s.spop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.rmop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==3 then
		s.tdop(e,tp,eg,ep,ev,re,r,rp)
	end
end

--==================== 选项1：从除外区特召1只哥布林怪兽（无视召唤条件） ====================
function s.spfilter(c)
	return c:IsSetCard(0xAC) and c:IsType(TYPE_MONSTER)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 【修复】限制只选择1只
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		-- ignore_condition=true 无视召唤条件
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end

--==================== 选项2：从卡组·手卡·墓地除外1只哥布林怪兽 ====================
function s.rmfilter(c)
	return c:IsSetCard(0xAC) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

--==================== 选项3：除外区3只哥布林返回卡组，抽1 ====================
function s.tdfilter(c)
	return c:IsSetCard(0xAC) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_REMOVED,0,3,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil)
	if #g<3 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:Select(tp,3,3,nil)
	if #sg<3 then return end
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	Duel.ShuffleDeck(tp)
	Duel.BreakEffect()
	Duel.Draw(tp,1,REASON_EFFECT)
end