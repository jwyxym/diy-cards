--缚魂灵-黑白无常
local s,id=GetID()
function s.initial_effect(c)
	-- ★ 1. 正规融合召唤手续
	c:EnableReviveLimit()
	aux.AddFusionProcMix(c,true,true,s.matfilter1,s.matfilter2)

	-- ★ 2. 替代召唤手续：把自己场上2只「缚魂灵」怪兽解放的场合可以从额外卡组特殊召唤（1回合1次）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.spcon)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)

	-- ① 特殊召唤成功时，确认对方额外，选1只除外，那之后可以选墓地/除外1张返回
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

	-- ② 双方回合，以对方场上1张卡为对象，那张卡加入自己卡组/额外
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.tgtg2)
	e2:SetOperation(s.tgop2)
	c:RegisterEffect(e2)

	-- ③ 送去墓地的场合，选对方墓地/除外最多2张卡加入自己卡组/额外，无视条件特召1只对方卡，自身回额外
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+200)
	e3:SetTarget(s.tgtg3)
	e3:SetOperation(s.tgop3)
	c:RegisterEffect(e3)
end

-- ================= 融合素材过滤 =================
function s.matfilter1(c)
	return c:IsLevel(6) and c:IsRace(RACE_ZOMBIE)
end

function s.matfilter2(c)
	return (c:IsSetCard(0x1fa3) and c:IsType(TYPE_MONSTER)) 
		or c:IsCode(8508055) 
		or c:GetOwner()~=c:GetControler()
end

-- ================= 替代特召手续 =================
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.CheckReleaseGroup(tp,s.relfilter,2,nil)
		and Duel.GetFlagEffect(tp,id)==0
end

function s.relfilter(c)
	return c:IsSetCard(0x1fa3) and c:IsType(TYPE_MONSTER) and c:IsReleasable()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=g:Select(tp,2,2,nil)
	if sg:GetCount()>0 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	end
	return false
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	local sg=e:GetLabelObject()
	if sg then
		Duel.Release(sg,REASON_COST)
		sg:DeleteGroup()
	end
end

-- ================= ① 效果 =================
function s.tgtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
end

function s.tgop1(e,tp,eg,ep,ev,re,r,rp)
	-- 1. 确认对方额外，选1只除外
	local g=Duel.GetFieldGroup(1-tp,LOCATION_EXTRA,0)
	if g:GetCount()>0 then
		Duel.ConfirmCards(tp, g)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=g:Select(tp,1,1,nil)
		if sg:GetCount()>0 then
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	end

	-- 2. 那之后，可以选墓地/除外1张返回
	local g2=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	if g2:GetCount()>0 then
		if Duel.SelectYesNo(tp, aux.Stringid(id, 4)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local sg2=g2:Select(tp,1,1,nil)
			if sg2:GetCount()>0 then
				local tc=sg2:GetFirst()
				Duel.SendtoDeck(tc,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
end

-- ================= ② 效果 =================
function s.tgtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToDeck() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end

function s.tgop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

-- ================= ③ 效果 =================
function s.tgtg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,nil)
			and Duel.IsExistingMatchingCard(s.spfilter3,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end

-- ★ 终极判定：连接怪兽落点检测
function s.spfilter3(c,e,tp)
	-- 只有原本持有者是对方的怪兽才能特召
	if c:GetOwner()~=1-tp or not c:IsType(TYPE_MONSTER) then return false end
	
	-- 如果是连接怪兽，用底层函数精准检测指向端
	if c:IsType(TYPE_LINK) then
		local zone = Duel.GetLocationCountFromEx(tp,tp,nil,c)
		if zone <= 0 then return false end
	else
		-- 非连接怪兽必须查主怪兽区
		if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return false end
	end
	
	return true
end

function s.tgop3(e,tp,eg,ep,ev,re,r,rp)
	-- 1. 选对方墓地/除外最多2张卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	if g:GetCount()>0 then
		local max_count = math.min(2, g:GetCount())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=g:Select(tp,1,max_count,nil)
		if sg:GetCount()>0 then
			for tc in aux.Next(sg) do
				Duel.SendtoDeck(tc,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end

	-- 2. 从卡组/额外无视条件特召1只原本持有者是对方的怪兽
	local g_sp=Duel.GetMatchingGroup(s.spfilter3,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil,e,tp)
	if g_sp:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg_sp=g_sp:Select(tp,1,1,nil)
		if sg_sp:GetCount()>0 then
			local tc=sg_sp:GetFirst()
			-- 强行拉怪（无视原主人的任何限制）
			local success = Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
			if success then
				-- 离场除外的Buff
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

	-- 3. 自身返回额外卡组
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_GRAVE) then
		Duel.SendtoDeck(c,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

return s