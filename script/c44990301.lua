--奥秘-变形药水
local s,id=GetID()
function s.initial_effect(c)
	-- ① 对方召唤·特殊召唤成功时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end

-- 发动条件：本回合发动次数少于2 + 对方场上有召唤·特召的怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)<2
		and eg:IsExists(Card.IsControler,1,nil,1-tp)
end

-- 目标：设置发动次数标志
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置发动次数标志（即使被无效也占用次数）
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	local g=eg:Filter(Card.IsControler,nil,1-tp)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,1-tp,0)
end

-- 操作：送墓 + 在对方场上特召等量绵羊衍生物
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsControler,nil,1-tp)
	if #g==0 then return end

	-- 将那些怪兽送去墓地
	local ct=Duel.SendtoGrave(g,REASON_EFFECT)
	if ct<=0 then return end

	-- 在对方场上特殊召唤最多ct只绵羊衍生物
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	local n=math.min(ct,ft)
	for i=1,n do
		local token=Duel.CreateToken(tp,44990300)
		Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
end