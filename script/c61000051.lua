-- 云剑·崩雪（ID: 61000051）通常陷阱
-- 效果文本：
--   这个卡名的①②的效果1回合只能有1次使用其中任意1个。自己回合，这张卡的发动从手卡也能用。
--   ①：连锁3以后才能发动。从自己卡组上面把这张卡的发动时积累的连锁数量的卡送去墓地。连锁「云剑」卡的效果把这张卡发动的场合，可以再给与对方基本分这张卡的发动时积累的连锁中「云剑」卡的数量×400的伤害。
--   ②：这张卡在墓地存在，自己在连锁2以后把「云剑」卡的效果发动时才能发动。这张卡加入手卡。
local s,id,o=GetID()
s.setcode=0xa7c0

function s.initial_effect(c)
	-- 手卡发动（只限自己回合）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.handcon)
	c:RegisterEffect(e0)

	-- ① 卡的发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)

	-- ② 墓地回收（二速：连锁响应）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.gycon)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end

function s.handcon(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end

-- 连锁3以后（自己作为连锁3以上发动）
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()>=2
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=Duel.GetCurrentChain()
	e:SetLabel(ct)
	-- 连锁中「云剑」卡的数量
	local yj=0
	for i=1,ct do
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		local h=te and te:GetHandler()
		if h and h:IsSetCard(s.setcode) then yj=yj+1 end
	end
	-- param = 云剑数×10 + 是否连锁云剑卡发动
	local prev=ct-1
	local te=prev>0 and Duel.GetChainInfo(prev,CHAININFO_TRIGGERING_EFFECT)
	local h=te and te:GetHandler()
	local flag=(h and h:IsSetCard(s.setcode)) and 1 or 0
	Duel.SetTargetParam(yj*10+flag)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if ct>0 then Duel.DiscardDeck(tp,ct,REASON_EFFECT) end
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if p%10~=1 then return end
	local yj=math.floor(p/10)
	if yj>0 then Duel.Damage(1-tp,yj*400,REASON_EFFECT) end
end

-- ② 条件：连锁2以后、自己把「云剑」卡的效果发动
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	if ev<2 or re==nil then return false end
	local h=re:GetHandler()
	return h~=nil and h:IsSetCard(s.setcode) and h:GetControler()==tp
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_GRAVE) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end
