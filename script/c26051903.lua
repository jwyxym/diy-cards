-- 新星同盟 星光对峙
-- ID: 26051903
-- 反击陷阱
local s,id=GetID()
function s.initial_effect(c)
	-- 反击效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- 自定义过滤：表侧且属于「新星同盟」(0x902)
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x902)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 一回合一次
	if Duel.GetFlagEffect(tp,id)>0 then return false end
	-- 对方发动怪兽效果，且自己场上有「新星同盟」怪兽
	return re:IsActiveType(TYPE_MONSTER) and rp==1-tp
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 注册一回合一次标记
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	Duel.NegateActivation(ev)
end