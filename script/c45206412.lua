--缚魂灵-望乡台
local s,id=GetID()
function s.initial_effect(c)
	-- 卡片发动（永续魔法）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- ① 解放不死族，检索卡（1回合1次，独立次数）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id) 
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- ② 展示对方卡，先洗切自己墓地/除外，那之后塞给对方手卡（1回合1次，独立次数）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+100) 
	e2:SetCost(s.drcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end

-- ================= ① 效果 =================

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.CheckReleaseGroup(tp,s.relfilter,1,nil) 
			or Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_EXTRA+LOCATION_HAND,0,1,nil)
	end
	local g=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_EXTRA,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=g:Select(tp,1,1,nil)
	Duel.Release(sg,REASON_COST)
end

function s.relfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsReleasable()
end

function s.thfilter(c,tp)
	if c:IsSetCard(0x1fa3) and c:IsType(TYPE_MONSTER) then return true end
	if c:GetOwner()==1-tp then return true end
	return false
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 誓约限制
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,tp)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		if sg:GetCount()>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleDeck(tp)
		end
	end
end

-- 官方同款自诉判定
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) 
		and not c:IsSetCard(0x1fa3) 
		and c:GetOwner() ~= 1 - e:GetHandlerPlayer()
end

-- ================= ② 效果 =================

-- 过滤：手卡里原本持有者是对方的卡
function s.drfilter(c,tp)
	return c:GetOwner()==1-tp
end

-- Cost：展示手卡，并记录到 Label 中供 OP 阶段使用
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.drfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
	local g = Duel.SelectMatchingCard(tp, s.drfilter, tp, LOCATION_HAND, 0, 1, 1, nil, tp)
	if g:GetCount()>0 then
		local tc = g:GetFirst()
		-- 展示给对面看
		Duel.ConfirmCards(1-tp, tc)
		-- 存入 Label
		e:SetLabelObject(tc)
	end
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地/除外是否有卡可以返回
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- ★ 步骤1：先选自己墓地/除外最多5张卡返回卡组
	local g = Duel.GetMatchingGroup(Card.IsAbleToDeck, tp, LOCATION_GRAVE+LOCATION_REMOVED, 0, nil)
	if g:GetCount()>0 then
		local max_count = math.min(5, g:GetCount())
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
		local sg = g:Select(tp, 1, max_count, nil)
		if sg:GetCount()>0 then
			Duel.SendtoDeck(sg, tp, SEQ_DECKSHUFFLE, REASON_EFFECT)
		end
	end

	-- ★ 步骤2：那之后，把展示的卡塞回对方手卡
	local tc = e:GetLabelObject()
	if tc and tc:IsLocation(LOCATION_HAND) then
		Duel.BreakEffect()
		Duel.SendtoHand(tc, 1-tp, REASON_EFFECT)
		Duel.ConfirmCards(tp, tc)
		Duel.ShuffleHand(tp)
		Duel.ShuffleHand(1-tp)
	end
end

return s