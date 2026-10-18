--落井下石
local s,id=GetID()
function s.initial_effect(c)
	--从手卡发动：对方有卡送去墓地·除外的这个回合，这张卡的发动从手卡也能用
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.handcon)
	c:RegisterEffect(e0)

	--监视：对方有卡送去墓地时打标记
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND+LOCATION_SZONE)
	e1:SetCondition(s.flagcon)
	e1:SetOperation(s.flagop)
	c:RegisterEffect(e1)

	--监视：对方有卡除外时打标记
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_HAND+LOCATION_SZONE)
	e2:SetCondition(s.flagcon)
	e2:SetOperation(s.flagop)
	c:RegisterEffect(e2)

	--① 对方墓地·除外状态的卡的效果发动时才能发动。那个效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end

-- 手卡发动条件：本回合标记存在
function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetFlagEffect(tp,id)~=0
end

-- 标记条件：对方的卡送墓/除外
function s.flagcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end

-- 打标记
function s.flagop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

-- ① 条件：对方墓地·除外区的卡的效果发动
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	if not re then return false end
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return loc==LOCATION_GRAVE or loc==LOCATION_REMOVED
end

-- ① target
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end

-- ① operation：无效那个效果
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

return s
