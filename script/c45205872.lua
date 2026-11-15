--春种秋收
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	
	Duel.AddCustomActivityCounter(id, ACTIVITY_CHAIN, s.counterfilter)
end

function s.counterfilter(c)
	if not c then return true end
	return c:GetCode() == id 
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
		and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0
		and Duel.GetCustomActivityCount(id, tp, ACTIVITY_CHAIN)==0 
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetChainLimit(s.chainlimit)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	
	-- 1. 手卡洗回卡组
	local g = Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
	if g:GetCount() > 0 then
		Duel.SendtoDeck(g, tp, SEQ_DECKSHUFFLE, REASON_EFFECT)
	end
	
	-- 2. 改变下个抽卡阶段的通常抽卡数量
	local e_draw=Effect.CreateEffect(c)
	e_draw:SetType(EFFECT_TYPE_FIELD)
	e_draw:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e_draw:SetCode(EFFECT_DRAW_COUNT)
	e_draw:SetTargetRange(1,0)
	e_draw:SetCondition(s.drcon)
	e_draw:SetValue(s.drval)
	e_draw:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN) 
	Duel.RegisterEffect(e_draw, tp)
	
	-- 3. 挂上死锁：这回合除了这张卡，自己不能发其他卡
	local e_lock=Effect.CreateEffect(c)
	e_lock:SetType(EFFECT_TYPE_FIELD)
	e_lock:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e_lock:SetCode(EFFECT_CANNOT_ACTIVATE)
	e_lock:SetTargetRange(1,0)
	e_lock:SetValue(s.aclimit)
	e_lock:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e_lock,tp)
end

function s.drcon(e)
	return Duel.GetCurrentPhase()==PHASE_DRAW
end

function s.drval(e)
	local tp = e:GetHandlerPlayer()
	local ct_hand = Duel.GetFieldGroupCount(tp, 0, LOCATION_HAND)
	local ct_field = Duel.GetFieldGroupCount(tp, 0, LOCATION_ONFIELD)
	return ct_hand + ct_field
end

function s.chainlimit(e,ep,tp)
	return ep ~= tp 
end

function s.aclimit(e,re,tp)
	local rc = re:GetHandler()
	if not rc then return true end
	return rc:GetCode() ~= id
end

return s