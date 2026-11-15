-- 云剑·闪风（ID: 61000050）通常陷阱
-- 效果文本：
--   这个卡名的①②的效果1回合只能有1次使用其中任意1个。自己回合，这张卡的发动从手卡也能用。
--   ①：以这张卡以外的自己墓地1张「云剑」陷阱卡为对象才能发动。这个效果变成和那张卡发动时的效果相同。连锁「云剑」卡的效果把这张卡发动的场合，可以再从卡组把1张「云剑」卡送去墓地。
--   ②：这张卡在墓地存在，自己在连锁2以后把「云剑」卡的效果发动时才能发动。这张卡加入手卡。
local s,id,o=GetID()
s.setcode=0xa7c0
s.copyflag=id+1

function s.initial_effect(c)
	-- 手卡发动（只限自己回合）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.handcon)
	c:RegisterEffect(e0)

	-- ① 卡的发动（复制墓地云剑陷阱的效果）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
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

function s.cpfilter(c,ec)
	return c~=ec and c:IsType(TYPE_TRAP) and c:IsSetCard(s.setcode)
		and c:CheckActivateEffect(false,true,false)~=nil
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te and te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then return Duel.IsExistingTarget(s.cpfilter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler())
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	e:SetProperty(te:GetProperty())
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
	-- 这张卡是不是连锁「云剑」卡的效果发动（用 flag 记，避免与复制来的效果抢 label）
	local ct=Duel.GetCurrentChain()
	local prev=ct-1
	local te2=prev>0 and Duel.GetChainInfo(prev,CHAININFO_TRIGGERING_EFFECT)
	local h=te2 and te2:GetHandler()
	if h and h:IsSetCard(s.setcode) then
		e:GetHandler():RegisterFlagEffect(s.copyflag,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local te=e:GetLabelObject()
	if not te then return end
	local tc=te:GetHandler()
	local ok=tc:IsRelateToEffect(e) and tc:GetType()==TYPE_TRAP
	if ok then
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
	end
	-- 追加：连锁「云剑」卡的效果发动的场合，从卡组把1张「云剑」卡送墓
	if c:GetFlagEffect(s.copyflag)==0 then return end
	if Duel.GetMatchingGroupCount(s.millfilter,tp,LOCATION_DECK,0,nil)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.millfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
end

function s.millfilter(c)
	return c:IsSetCard(s.setcode) and c:IsAbleToGrave()
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
