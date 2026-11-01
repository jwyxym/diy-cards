--奥秘-异议！
local s,id=GetID()
function s.initial_effect(c)
	-- ① 对方通常召唤时
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

	-- ① 对方反转召唤时
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)

	-- ① 对方特殊召唤时
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
end

-- 发动条件：对方怪兽召唤·反转召唤·特殊召唤 + 自己场上有「奥秘」怪兽 + 同名卡本回合发动次数<2
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
		and Duel.IsExistingMatchingCard(s.afilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetFlagEffect(tp,id)<2
end

-- 「奥秘」怪兽过滤
function s.afilter(c)
	return c:IsFaceup() and c:IsSetCard(0x0cf2) and c:IsType(TYPE_MONSTER)
end

-- 目标：设置同名卡发动次数标志
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,eg:GetCount(),0,0)
	if eg:IsExists(Card.IsDestructable,1,nil) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
	end
end

-- 操作：无效召唤并破坏
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateSummon(eg) then
		Duel.BreakEffect()
		Duel.Destroy(eg,REASON_EFFECT)
	end
end