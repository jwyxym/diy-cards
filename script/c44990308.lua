--奥秘-爆炸陷阱
local s,id=GetID()
function s.initial_effect(c)
	-- ① 对方怪兽效果发动时，破坏并给予原本攻击力一半伤害
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

-- 发动条件：自己场上有「奥秘」怪兽 + 对方怪兽效果发动 + 同名卡本回合发动次数<2
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
		and re and re:IsActiveType(TYPE_MONSTER)
		and Duel.IsExistingMatchingCard(s.afilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetFlagEffect(tp,id)<2
end

-- 「奥秘」怪兽过滤
function s.afilter(c)
	return c:IsFaceup() and c:IsSetCard(0x0cf2) and c:IsType(TYPE_MONSTER)
end

-- 目标：注册同名卡发动次数标志
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	local tc=re:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end

-- 操作：破坏怪兽并给予原本攻击力一半的伤害
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if not tc or not tc:IsRelateToEffect(re) then return end
	local atk=tc:GetBaseAttack()
	local dmg=math.floor(atk/2)
	if dmg<0 then dmg=0 end
	if Duel.Destroy(tc,REASON_EFFECT)~=0 and dmg>0 then
		Duel.Damage(1-tp,dmg,REASON_EFFECT)
	end
end