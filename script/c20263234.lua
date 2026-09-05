-- 永续陷阱 木偶忍者-七方出 (ID: 20263234)
local s,id,o=GetID()
local SET_NINJITSU=0x61 -- 「忍法」字段代码

function s.initial_effect(c)
	-- 规则效果：这张卡在规则上也当作「忍法」卡使用
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(SET_NINJITSU)
	c:RegisterEffect(e0)

	-- ①：以对方场上1只表侧怪兽为对象发动：变成同种族效果怪兽守备表示特召 (①②共享 HOPT: id)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetCondition(s.trapactcon) -- 严格防手发物理锁
	e1:SetCountLimit(1,id) -- 共享 HOPT
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- ① 效果赋予特召怪兽的常驻效果1：●特殊召唤成功的场合选对方同种族怪兽盖放且不能变表示形式
	local e1_sub1=Effect.CreateEffect(c)
	e1_sub1:SetDescription(aux.Stringid(id,2))
	e1_sub1:SetCategory(CATEGORY_POSITION)
	e1_sub1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1_sub1:SetProperty(EFFECT_FLAG_DELAY)
	e1_sub1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1_sub1:SetRange(LOCATION_MZONE)
	e1_sub1:SetCondition(s.trapmoncon)
	e1_sub1:SetTarget(s.postg)
	e1_sub1:SetOperation(s.posop)
	c:RegisterEffect(e1_sub1)

	-- ① 效果赋予特召怪兽的常驻效果2：●这张卡不会被效果破坏
	local e1_sub2=Effect.CreateEffect(c)
	e1_sub2:SetType(EFFECT_TYPE_SINGLE)
	e1_sub2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1_sub2:SetRange(LOCATION_MZONE)
	e1_sub2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1_sub2:SetCondition(s.trapmoncon)
	e1_sub2:SetValue(1)
	c:RegisterEffect(e1_sub2)

	-- ②：墓地存在，对方怪兽攻击宣言时以该怪兽为对象发动：变成同属性通常怪兽特召，离场盖放 (①②共享 HOPT: id)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id) -- 共享 HOPT
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

-- ==================== 防手发物理硬锁 ====================
function s.trapactcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_SZONE)
end

-- 判定当前卡片是否作为效果陷阱怪兽在场存在
function s.trapmoncon(e)
	local c=e:GetHandler()
	return c:IsType(TYPE_EFFECT) and c:IsType(TYPE_TRAP) and c:IsLocation(LOCATION_MZONE)
end

-- ==================== ① 效果：特召为效果怪兽 ====================
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:IsCostChecked()
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_NINJITSU,TYPE_MONSTER+TYPE_EFFECT+TYPE_TRAP,0,3000,4,RACE_ALL,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) then return end
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local race=tc:GetRace()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_NINJITSU,TYPE_MONSTER+TYPE_EFFECT+TYPE_TRAP,0,3000,4,race,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) then return end
	
	-- 赋予怪兽属性（同种族·地属性·4星·攻0/守3000）
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP,ATTRIBUTE_EARTH,race,4,0,3000)
	-- 执行特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_DEFENSE)
end

-- ① 效果特召成功的盖怪处理
function s.posfilter(c,race)
	return c:IsFaceup() and c:IsRace(race) and c:IsCanTurnSet()
end

function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil,c:GetRace()) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,LOCATION_MZONE)
end

function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil,c:GetRace())
	local tc=g:GetFirst()
	if tc and Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)>0 then
		-- 对方不能把这个效果盖放的怪兽的表示形式变更
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end

-- ==================== ② 效果：墓地特召为通常怪兽 & 离场必回盖 ====================
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local at=Duel.GetAttacker()
	if chkc then return chkc==at end
	local c=e:GetHandler()
	if chk==0 then return at and at:IsControler(1-tp) and at:IsCanBeEffectTarget(e)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_MONSTER+TYPE_NORMAL,0,3000,4,RACE_MACHINE,at:GetAttribute(),POS_FACEUP) end
	Duel.SetTargetCard(at)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) then return end
	if not tc or not tc:IsRelateToEffect(e) then return end
	local att=tc:GetAttribute()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_MONSTER+TYPE_NORMAL,0,3000,4,RACE_MACHINE,att,POS_FACEUP) then return end
	
	-- 变成同属性通常怪兽（机械族·4星·攻0/守3000）
	c:AddMonsterAttribute(TYPE_NORMAL,att,RACE_MACHINE,4,0,3000)
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)>0 then
		-- ★ 修复重点：不绑定导致提前注销的 RESETS_STANDARD，确保离场时 100% 触发监听
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCondition(s.setcon)
		e1:SetOperation(s.setop)
		c:RegisterEffect(e1,true)
	end
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and not c:IsLocation(LOCATION_DECK)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ★ 修复重点：使用 MoveToField 绕过伤害步骤对 SSet 的底层限制，100% 盖回魔陷区
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
	e:Reset() -- 完成回盖后重置销毁该监听
end