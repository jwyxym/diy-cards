--哥布林之王 高格
--卡密ID: 45205511
--字段代码: 0xAC

local s,id=GetID()

function s.initial_effect(c)
	--不能通常召唤
	c:EnableReviveLimit()
	
	--不能从手卡里侧盖放
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e0)
	
	--只能用自身效果或特定无视召唤条件的效果特殊召唤
	local e_limit=Effect.CreateEffect(c)
	e_limit:SetType(EFFECT_TYPE_SINGLE)
	e_limit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e_limit:SetCode(EFFECT_SPSUMMON_CONDITION)
	e_limit:SetValue(s.splimit)
	c:RegisterEffect(e_limit)
	
	--特殊召唤手续（场上·除外状态5只哥布林返回卡组）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	
	--①效果：除外场上·墓地1只哥布林，从额外·卡组·除外区特召1只10星以下哥布林（除自身外）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	
	--②效果：自己只能特殊召唤哥布林怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit2)
	e3:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e3)
	
	--③效果：这张卡被除外的场合，选场上1张卡除外，然后返回卡组（不取对象）
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+200)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop2)
	c:RegisterEffect(e4)
end

--特殊召唤限制：只能用自身效果或特定卡的效果
function s.splimit(e,se,sp,st)
	if se and se:GetHandler()==e:GetHandler() then
		return true
	end
	if se then
		local code=se:GetHandler():GetOriginalCode()
		if code==45205509 or code==45205510 then
			return true
		end
	end
	return false
end

--特殊召唤条件：场上·除外状态5只哥布林返回卡组
function s.costfilter(c)
	return c:IsSetCard(0xAC) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g1=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_ONFIELD,0,nil)
	local g2=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_REMOVED,0,nil)
	g1:Merge(g2)
	return g1:GetCount()>=5
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g1=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_ONFIELD,0,nil)
	local g2=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_REMOVED,0,nil)
	g1:Merge(g2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g1:Select(tp,5,5,nil)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

--①效果Cost：除外场上·墓地1只哥布林怪兽
function s.rmcostfilter(c)
	return c:IsSetCard(0xAC) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end

function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.rmcostfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmcostfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

--①效果：从额外·卡组·除外区特召1只10星以下哥布林（除自身外，无视召唤条件）
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xAC) and c:IsType(TYPE_MONSTER) and c:GetLevel()<=10
		and c:GetCode()~=id
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA+LOCATION_DECK+LOCATION_REMOVED,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_DECK+LOCATION_REMOVED)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	
	local g1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	local g2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	local g3=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	local g=Group.CreateGroup()
	g:Merge(g1)
	g:Merge(g2)
	g:Merge(g3)
	if #g==0 then return end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,1,nil)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
	end
end

--②效果自肃：只能特殊召唤哥布林怪兽
function s.splimit2(e,c)
	return not c:IsSetCard(0xAC)
end

--③效果：选场上1张卡除外，然后返回卡组（不取对象）
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function s.rmop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end