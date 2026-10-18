--春种秋收
local s,id=GetID()
function s.initial_effect(c)
	--① 对方的准备阶段，自己场上没有卡的场合把这张卡从手卡丢弃才能发动。
	--   这个回合的结束阶段，自己抽出对方场上卡的数量的卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

-- 条件：对方的准备阶段，自己场上没有卡
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
		and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0
end

-- cost：从手卡丢弃这张卡自身
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

-- target
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

-- operation：注册结束阶段抽卡
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 注册结束阶段抽卡效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(s.drcon)
	e1:SetOperation(s.drop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

-- 结束阶段抽卡条件
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return true
end

-- 结束阶段抽卡：抽出对方场上卡的数量
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if ct>0 then
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
	e:Reset()
end

return s
