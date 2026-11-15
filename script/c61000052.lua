-- 云剑·游龙（ID: 61000052）通常陷阱
-- 效果文本：
--   这个卡名的①②的效果1回合只能有1次使用其中任意1个。自己回合，这张卡的发动从手卡也能用。
--   ①：选这张卡以外的手卡·场上的2张陷阱卡送去墓地才能发动（这个效果发动的回合，自己若非不能通常召唤的怪兽则不能特殊召唤，也不能把那个的怪兽效果发动）。卡组的1张「云剑」卡加入手卡。连锁「云剑」卡的效果把这张卡发动的场合，可以再从卡组抽1张。
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
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
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

-- 费用：这张卡以外的手卡·场上2张陷阱卡送墓
function s.cfilter(c,ec)
	return c~=ec and c:IsType(TYPE_TRAP) and c:IsAbleToGraveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,2,nil,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,2,2,nil,e:GetHandler())
	Duel.SendtoGrave(g,REASON_COST)
end

function s.thfilter(c)
	return c:IsSetCard(s.setcode) and c:IsAbleToHand()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 这张卡是不是连锁「云剑」卡的效果发动
	-- 连锁「云剑」卡 = 前一个连锁（ct 是自己这一条）
	local ct=Duel.GetCurrentChain()
	local prev=ct-1
	local te=prev>0 and Duel.GetChainInfo(prev,CHAININFO_TRIGGERING_EFFECT)
	local h=te and te:GetHandler()
	Duel.SetTargetParam((h and h:IsSetCard(s.setcode)) and 1 or 0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	s.applylimit(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	if Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)~=1 then return end
	-- 追加：连锁云剑卡发动的场合，可以再抽1
	if Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

-- 自肃：只能特召不能通常召唤的怪兽；不能把怪兽效果发动
function s.applylimit(e,tp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetTargetRange(1,0)
	e2:SetValue(s.actlimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end

-- 与 22420202 同款检测
function s.splimit(e,c)
	return c:IsSummonableCard() and c:GetOriginalType()&(TYPE_SPELL|TYPE_TRAP|TYPE_TRAPMONSTER)==0
end

function s.actlimit(e,re,rp)
	local h=re:GetHandler()
	return h~=nil and h:IsType(TYPE_MONSTER) and h:IsSummonableCard()
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
