--缚魂灵-谢必安
local s,id=GetID()
function s.initial_effect(c)
	-- ① 召唤成功时：除外对方额外1只，那之后可以选对方墓地/除外1张返回（无次数限制）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	-- ★ 核心修复：必须是 EVENT_SUMMON_SUCCESS（通常召唤）
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.tgtg1)
	e1:SetOperation(s.tgop1)
	c:RegisterEffect(e1)

	-- ② 被解放时：检索1张卡，那之后可以把手卡1只怪兽召唤（1回合1次）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.rltg2)
	e2:SetOperation(s.rlop2)
	c:RegisterEffect(e2)

	-- ③ 除外对方卡，处理时解放本家（1回合1次）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_RELEASE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE) 
	e3:SetCountLimit(1,id+200)
	e3:SetCost(s.rlcost3)
	e3:SetTarget(s.rltg3)
	e3:SetOperation(s.rlop3)
	c:RegisterEffect(e3)
end

-- ================= ① 效果 =================

function s.tgtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_EXTRA,0)>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
end

function s.tgop1(e,tp,eg,ep,ev,re,r,rp)
	-- 1. 随机除外对方额外卡组1张
	local g=Duel.GetFieldGroup(1-tp,LOCATION_EXTRA,0)
	if g:GetCount()>0 then
		local sg=g:RandomSelect(tp,1)
		if sg:GetCount()>0 then
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	end

	-- 2. 那之后，可以选对方墓地/除外1张返回（弹窗询问）
	local g2=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	if g2:GetCount()>0 then
		if Duel.SelectYesNo(tp, aux.Stringid(id, 4)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local sg2=g2:Select(tp,1,1,nil)
			if sg2:GetCount()>0 then
				local tc=sg2:GetFirst()
				if tc:IsType(TYPE_MONSTER) and tc:IsExtraDeckMonster() then
					Duel.SendtoDeck(tc,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
				else
					Duel.SendtoDeck(tc,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
				end
			end
		end
	end
end

-- ================= ② 效果 =================

function s.rlfilter2(c,tp)
	if c:IsSetCard(0x1fa3) and c:IsType(TYPE_SPELL+TYPE_TRAP) then return true end
	if c:GetOwner()==1-tp then return true end
	return false
end

function s.rltg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rlfilter2,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.rlop2(e,tp,eg,ep,ev,re,r,rp)
	-- 1. 拿卡
	local g=Duel.GetMatchingGroup(s.rlfilter2,tp,LOCATION_DECK,0,nil,tp)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		if sg:GetCount()>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleDeck(tp)
		end
	end

	-- 2. 那之后，可以把手卡1只怪兽召唤
	local sum_g = Duel.GetMatchingGroup(function(c) return c:IsSummonable(true, nil) end, tp, LOCATION_HAND, 0, nil)
	if sum_g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		if Duel.SelectYesNo(tp, aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local sg_sum=sum_g:Select(tp,1,1,nil)
			if sg_sum:GetCount()>0 then
				Duel.Summon(tp, sg_sum:GetFirst(), true, nil)
			end
		end
	end
end

-- ================= ③ 效果 =================

function s.rlcost3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.conremfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil,tp)
	end
	local g=Duel.GetMatchingGroup(s.conremfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:Select(tp,1,1,nil)
	if sg:GetCount()>0 then
		Duel.Remove(sg,POS_FACEUP,REASON_COST)
	end
end

function s.conremfilter(c,tp)
	return c:GetOwner()==1-tp and c:IsAbleToRemoveAsCost()
end

function s.rltg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.rlfilter3,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end

function s.rlfilter3(c)
	return c:IsSetCard(0x1fa3) and c:IsType(TYPE_MONSTER) and c:IsReleasable()
end

function s.rlop3(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rlfilter3,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local sg=g:Select(tp,1,1,nil)
		if sg:GetCount()>0 then
			Duel.Release(sg,REASON_EFFECT)
			Duel.RaiseEvent(sg,EVENT_RELEASE,nil,REASON_EFFECT,tp,tp,0)
			Duel.BreakEffect() 
		end
	end
end

return s