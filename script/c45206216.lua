--双截棍
local s,id=GetID()
function s.initial_effect(c)
	-- 记述了「格斗鼠 吱助」
	aux.AddCodeList(c,8508055)

	-- ① 发动（装备卡的标准写法）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

	-- ② 装备对象限制
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	c:RegisterEffect(e2)

	-- ③ 攻击力上升800
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(800)
	c:RegisterEffect(e3)

	-- ④ 战破不入连锁烧血（给与原本攻击力数值的伤害）
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS) -- 永续效果，监听事件
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.damcon)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
end

-- 装备限制：只能装备给格斗鼠（包括场上改名的截道鼠）
function s.eqlimit(e,c)
	return (c:IsCode(8508055) or c:IsOriginalCodeRule(8508055)) and c:IsControler(e:GetHandlerPlayer())
end

function s.filter(c)
	return c:IsFaceup() and (c:IsCode(8508055) or c:IsOriginalCodeRule(8508055))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end

-- 触发条件
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	if not ec then return false end
	local bc=ec:GetBattleTarget()
	return ec==e:GetHandler():GetEquipTarget() and bc and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE)
end

-- 效果处理（不入连锁造成伤害）
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	if not ec then return end
	-- ★ 修改：获取原本攻击力
	local dam=ec:GetBaseAttack() 
	if dam>0 then
		Duel.Damage(1-tp, dam, REASON_EFFECT)
	end
end

return s
