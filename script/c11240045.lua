-- 冰墙 (11240045)
local s,id,o=GetID()

function s.initial_effect(c)
	-- ①：直到下个回合结束对方攻击需回手卡到卡组，下个回合结束时抽卡
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	-- 攻击限制：直到下个回合结束，对方怪兽攻击宣言时必须把1张手卡返回卡组
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_ATTACK_COST)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCost(s.atcost)
	e1:SetOperation(s.atop)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)

	-- 为对方挂载限制提示标签（ClientHint）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e0:SetDescription(aux.Stringid(id,1))
	e0:SetTargetRange(0,1)
	e0:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e0,tp)

	-- 下个回合结束时延迟抽卡监听
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetLabel(Duel.GetTurnCount())
	e2:SetCondition(s.drcon)
	e2:SetOperation(s.drop)
	e2:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e2,tp)
end

-- ==================== 攻击代价逻辑 ====================

function s.atcost(e,c,tp)
	-- 攻击方（对方）手卡必须有能回卡组的卡
	return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil)
end

function s.atop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		-- 【彻底修复 1】：任意手卡回卡组，严禁执行 ConfirmCards，直接里侧洗回卡组
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	end
end

-- ==================== 延迟抽卡逻辑 ====================

function s.drfilter(c)
	-- 本回合没有进行过攻击（未攻击且未攻击宣言）的怪兽
	return c:GetAttackedCount()==0 and c:GetAttackAnnouncedCount()==0
end

function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 【彻底修复 2】：前置校验！必须是在下个回合结束阶段，且自己能抽卡，且对方场上确实存在未攻击过的怪兽
	-- 若未攻击怪兽数为 0，Condition 直接为 false，不产生任何多余效果处理
	return Duel.GetTurnCount()>e:GetLabel()
		and Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingMatchingCard(s.drfilter,tp,0,LOCATION_MZONE,1,nil)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.drfilter,tp,0,LOCATION_MZONE,nil)
	local ct=math.min(#g,1)
	if ct>0 then
		Duel.Hint(HINT_CARD,0,id)
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end