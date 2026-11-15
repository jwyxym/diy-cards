-- 云剑·凌波（ID: 61000046）通常陷阱
-- 效果文本：
--   这个卡名的①②的效果1回合只能有1次使用其中任意1个。自己回合，这张卡的发动从手卡也能用。
--   ①：连锁2以后才能发动。从自己卡组上面把这张卡的发动时积累的连锁数量的卡送去墓地，自己回复那个数值×400的基本分。连锁「云剑」卡的效果把这张卡发动的场合，再让这个回合中以下效果适用。
--   ●每次双方在连锁2以后把卡的效果发动，自己场上守备表示的怪兽的守备力上升400，自己场上没有怪兽存在的场合，把1只「云影衍生物」（天使族·光·1星·攻/守800）特殊召唤。这衍生物不能攻击。
--   ●场上表侧守备表示的通常怪兽不受发动的效果影响，也不能把表示形式变更。
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
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_RECOVER)
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

-- 连锁2以后才能发动（发动时已有1条以上连锁，本卡成为连锁2+）
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()>=1
end

-- 记下「连锁数量的卡片」与「是否连锁云剑卡发动」（label=连锁数，targetparam=1/0）
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=Duel.GetCurrentChain()
	e:SetLabel(ct)
	-- 连锁「云剑」卡 = 前一个连锁（ct 是自己这一条）
	local prev=ct-1
	local te=prev>0 and Duel.GetChainInfo(prev,CHAININFO_TRIGGERING_EFFECT)
	local h=te and te:GetHandler()
	Duel.SetTargetParam((h and h:IsSetCard(s.setcode)) and 1 or 0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	if ct>0 then
		Duel.DiscardDeck(tp,ct,REASON_EFFECT)
		Duel.Recover(tp,ct*400,REASON_EFFECT)
	end
	if Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)~=1 then return end
	-- ●1 每次双方在连锁2以后发动效果：自己守备怪兽守备力+400；自己场上没怪兽就出衍生物
	local ea=Effect.CreateEffect(c)
	ea:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ea:SetCode(EVENT_CHAINING)
	ea:SetOperation(s.defop)
	ea:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ea,tp)
	-- ●2 表侧守备的通常怪兽不受发动的效果影响、不能变表示形式
	local eb=Effect.CreateEffect(c)
	eb:SetType(EFFECT_TYPE_FIELD)
	eb:SetCode(EFFECT_IMMUNE_EFFECT)
	eb:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	eb:SetTarget(s.dfilter)
	eb:SetValue(s.dvalue)
	eb:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(eb,tp)
	local ec=Effect.CreateEffect(c)
	ec:SetType(EFFECT_TYPE_FIELD)
	ec:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	ec:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	ec:SetTarget(s.dfilter)
	ec:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ec,tp)
end

function s.dfilter(e,c)
	return c:IsFaceup() and c:IsPosition(POS_FACEUP_DEFENSE) and c:IsType(TYPE_NORMAL)
end

function s.dvalue(e,te)
	return te:IsActivated()
end

function s.defop(e,tp,eg,ep,ev,re,r,rp)
	if ev<2 then return end
	local g=Duel.GetMatchingGroup(s.bufffilter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 自己场上没有怪兽的场合：本次连锁组建中不能特招，
	-- 改成等这次连锁处理完（EVENT_CHAIN_END）再特招
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local ed=Effect.CreateEffect(e:GetHandler())
	ed:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ed:SetCode(EVENT_CHAIN_END)
	ed:SetOperation(s.tokop)
	ed:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ed,tp)
end

function s.tokop(e,tp,eg,ep,ev,re,r,rp)
	e:Reset()
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local token=Duel.CreateToken(tp,61000054)
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e2)
end

function s.bufffilter(c)
	return c:IsFaceup() and c:IsPosition(POS_FACEUP_DEFENSE)
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
