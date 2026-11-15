--缚魂灵-牛头马面
local s,id=GetID()
function s.initial_effect(c)
	-- ★ 1. 正规融合召唤手续
	c:EnableReviveLimit()
	aux.AddFusionProcMix(c,true,true,s.matfilter1,s.matfilter2)

	-- ★ 2. 替代召唤手续：把手卡·场上2张原本持有者是对方的卡除外的场合特召
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.spcon)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)

	-- ① 特殊召唤成功时：除外对方卡组/额外各1张，那之后可以选对方墓地/除外最多2张加入自己卡组/额外
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg1)
	e1:SetOperation(s.tgop1)
	c:RegisterEffect(e1)

	-- ② 自己·对方的回合，解放自己场上1只怪兽，选对方墓地/除外1张加入卡组/额外，那之后无视条件特召对方卡并除外
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(s.rlcost)
	e2:SetTarget(s.rltg)
	e2:SetOperation(s.rlop)
	c:RegisterEffect(e2)

	-- ③ 被送去墓地的场合：双方选自身额外卡组1只怪兽解放
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_RELEASE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+200)
	e3:SetTarget(s.extg)
	e3:SetOperation(s.exop)
	c:RegisterEffect(e3)
end

-- ================= 融合素材与特召手续 =================

function s.matfilter1(c)
	return c:IsSetCard(0x1fa3) and c:IsType(TYPE_MONSTER)
end

function s.matfilter2(c)
	return c:GetOwner()~=c:GetControler() or c:IsCode(8508055)
end

function s.hspchk(g,tp,sc)
	return Duel.GetLocationCountFromEx(tp,tp,g,sc) > 0
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg = Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil,tp)
	return rg:CheckSubGroup(s.hspchk, 2, 2, tp, e:GetHandler())
end

function s.spcostfilter(c,tp)
	return c:GetOwner()~=tp 
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	if chk==0 then return true end
	local rg = Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil,tp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local sg = rg:SelectSubGroup(tp, s.hspchk, true, 2, 2, tp, e:GetHandler())
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else
		return false
	end
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	local sg=e:GetLabelObject()
	if sg then
		Duel.Remove(sg,POS_FACEUP,REASON_COST)
		sg:DeleteGroup()
	end
end

-- ================= ① 效果 =================

function s.tgtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1 = Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
	local b2 = Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0
	if chk==0 then return b1 or b2 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK+LOCATION_EXTRA)
end

function s.tgop1(e,tp,eg,ep,ev,re,r,rp)
	-- 1. 随机除外对方卡组1张
	local g1 = Duel.GetFieldGroup(1-tp, LOCATION_DECK, 0)
	if g1:GetCount()>0 then
		local sg1 = g1:RandomSelect(1-tp, 1)
		if sg1:GetCount()>0 then
			Duel.ConfirmCards(tp, sg1)
			Duel.Remove(sg1, POS_FACEUP, REASON_EFFECT)
		end
	end

	-- 2. 随机除外对方额外卡组1张
	local g2 = Duel.GetFieldGroup(1-tp, LOCATION_EXTRA, 0)
	if g2:GetCount()>0 then
		local sg2 = g2:RandomSelect(1-tp, 1)
		if sg2:GetCount()>0 then
			Duel.ConfirmCards(tp, sg2)
			Duel.Remove(sg2, POS_FACEUP, REASON_EFFECT)
		end
	end

	-- 3. 那之后，可以选对方墓地/除外最多2张卡加入自己卡组/额外洗切
	local g3 = Duel.GetMatchingGroup(Card.IsAbleToDeck, tp, 0, LOCATION_GRAVE+LOCATION_REMOVED, nil)
	if g3:GetCount()>0 then
		if Duel.SelectYesNo(tp, aux.Stringid(id, 4)) then
			Duel.BreakEffect()
			local max_count = math.min(2, g3:GetCount())
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
			local sg3 = g3:Select(tp, 1, max_count, nil)
			if sg3:GetCount()>0 then
				for tc in aux.Next(sg3) do
					Duel.SendtoDeck(tc,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
				end
			end
		end
	end
end

-- ================= ② 效果 =================

function s.rlcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	Duel.Release(g,REASON_COST)
end

function s.rltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.rlop(e,tp,eg,ep,ev,re,r,rp)
	-- 1. 选对方墓地/除外1张加入自己卡组/额外
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=g:Select(tp,1,1,nil)
		if sg:GetCount()>0 then
			local tc=sg:GetFirst()
			Duel.SendtoDeck(tc,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end

	-- 2. 从卡组/额外无视条件特召1只原本持有者是对方的怪兽
	local g_sp=Duel.GetMatchingGroup(s.spfilter_2,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil,e,tp)
	if g_sp:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg_sp=g_sp:Select(tp,1,1,nil)
		if sg_sp:GetCount()>0 then
			local tc=sg_sp:GetFirst()
			local success = Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
			if success then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetValue(LOCATION_REMOVED)
				e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
				tc:RegisterEffect(e1,true)
			end
		end
	end
end

-- ★ 终极判定：完美兼容连接怪兽的落点
function s.spfilter_2(c,e,tp)
	if c:GetOwner()~=1-tp or not c:IsType(TYPE_MONSTER) then return false end
	
	-- 如果是额外卡组的怪，走官方 GetLocationCountFromEx 判定
	if c:IsLocation(LOCATION_EXTRA) then
		if Duel.GetLocationCountFromEx(tp,tp,nil,c) <= 0 then return false end
	else
		-- 如果是主卡组怪，走主区格子判定
		if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return false end
	end
	return true
end

-- ================= ③ 效果 =================

function s.extg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1 = Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)>0
	local b2 = Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0
	if chk==0 then return b1 or b2 end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,0,PLAYER_ALL,LOCATION_EXTRA)
end

function s.exop(e,tp,eg,ep,ev,re,r,rp)
	-- 对方选1张额外卡组怪兽解放
	local g2 = Duel.GetFieldGroup(1-tp, LOCATION_EXTRA, 0)
	if g2:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG, 1-tp, HINTMSG_RELEASE)
		local sg2 = g2:Select(1-tp, 1, 1, nil)
		if sg2:GetCount()>0 then
			Duel.Release(sg2, REASON_EFFECT)
		end
	end

	-- 自己选1张额外卡组怪兽解放
	local g1 = Duel.GetFieldGroup(tp, LOCATION_EXTRA, 0)
	if g1:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
		local sg1 = g1:Select(tp, 1, 1, nil)
		if sg1:GetCount()>0 then
			Duel.Release(sg1, REASON_EFFECT)
		end
	end
end

return s