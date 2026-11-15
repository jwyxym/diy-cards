--缚魂灵-鬼门关
local s,id=GetID()
function s.initial_effect(c)
	-- ① 通常魔法发动：解放自己额外1只，空场则对面额外除外1只，并附带自诉
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rltg)
	e1:SetOperation(s.rlop)
	c:RegisterEffect(e1)

	-- ② 墓地除外自身：解放手卡/场上本家，回收最多3张本家怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.rltg2)
	e2:SetOperation(s.rlop2)
	c:RegisterEffect(e2)
end

-- ================= ① 效果 =================

-- 选自己额外1只怪兽
function s.extra_filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end

function s.rltg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 必须有自己额外怪可以解放
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.extra_filter,tp,LOCATION_EXTRA,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
end

function s.rlop(e,tp,eg,ep,ev,re,r,rp)
	-- 1. 解放自己额外卡组1只怪兽
	local g1 = Duel.GetMatchingGroup(s.extra_filter, tp, LOCATION_EXTRA, 0, nil)
	if g1:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
		local sg1 = g1:Select(tp, 1, 1, nil)
		Duel.Release(sg1, REASON_COST)
	end

	-- 2. ★ 核心修复：只有自己场上没有怪兽时，对面才选额外卡组除外
	if Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) == 0 then
		local g2 = Duel.GetFieldGroup(1-tp, LOCATION_EXTRA, 0)
		if g2:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG, 1-tp, HINTMSG_REMOVE) -- 让对方自己选
			local sg2 = g2:Select(1-tp, 1, 1, nil)
			if sg2:GetCount()>0 then
				Duel.Remove(sg2, POS_FACEUP, REASON_EFFECT)
			end
		end
	end

	-- 3. 誓约限制（只限制额外卡组特召）
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

-- 自诉精准判定
function s.splimit(e,c,tp,sumtp,sumpos)
	if sumtp and (sumtp & LOCATION_EXTRA) ~= 0 then
		return not (c:IsSetCard(0x1fa3) or c:GetOwner()~=e:GetHandlerPlayer())
	end
	return false
end

-- ================= ② 效果 =================

-- 解放过滤：手卡/场上的本家怪兽
function s.rlfilter2(c)
	return c:IsSetCard(0x1fa3) and c:IsType(TYPE_MONSTER) and c:IsReleasable()
end

-- 回收过滤：墓地/除外的本家怪兽
function s.tdfilter(c)
	return c:IsSetCard(0x1fa3) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end

function s.rltg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.CheckReleaseGroup(tp,s.rlfilter2,1,nil)
			and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.rlop2(e,tp,eg,ep,ev,re,r,rp)
	-- 1. 解放手卡/场上1只「缚魂灵」怪兽
	local g1 = Duel.GetMatchingGroup(s.rlfilter2, tp, LOCATION_HAND+LOCATION_MZONE, 0, nil)
	if g1:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
		local sg1 = g1:Select(tp, 1, 1, nil)
		Duel.Release(sg1, REASON_EFFECT)
	end

	-- 2. 选自己墓地/除外最多3只「缚魂灵」怪兽返回卡组
	local g2 = Duel.GetMatchingGroup(s.tdfilter, tp, LOCATION_GRAVE+LOCATION_REMOVED, 0, nil)
	if g2:GetCount()>0 then
		local max_count = math.min(3, g2:GetCount())
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
		local sg2 = g2:Select(tp, 1, max_count, nil)
		if sg2:GetCount()>0 then
			Duel.SendtoDeck(sg2, tp, SEQ_DECKSHUFFLE, REASON_EFFECT)
		end
	end
end

return s
