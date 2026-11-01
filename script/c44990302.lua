--奥秘-秘法诱导
local s,id=GetID()
function s.initial_effect(c)
	-- ① 对方怪兽攻击宣言时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

-- 发动条件：对方怪兽攻击宣言 + 同名卡本回合发动次数少于2
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()~=nil
		and Duel.GetAttacker():IsControler(1-tp)
		and Duel.GetFlagEffect(tp,id)<2
end

-- 目标：取攻击怪兽为对象，注册同名卡发动次数标志
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=Duel.GetAttacker()
	if chk==0 then return tc and tc:IsRelateToBattle() end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,Group.FromCards(tc),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_MZONE)
end

-- 操作：无效攻击，送墓攻击怪兽，然后特殊召唤绵羊衍生物
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToBattle() then return end

	-- 无效攻击
	Duel.NegateAttack()

	-- 把攻击怪兽送去墓地
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end

	-- 在对方场上特殊召唤1只绵羊衍生物
	local token=Duel.CreateToken(tp,44990300)
	Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	Duel.SpecialSummonComplete()
end