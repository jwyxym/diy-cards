-- 创炎之构-段落曲线 (ID: 23600110)
local s,id,o=GetID()
local SET_CHOUEN=0xd85 -- 「创炎」字段

function s.initial_effect(c)
	-- 连接召唤手续：「创炎」怪兽3只以上 (LINK-4)
	local e0=aux.AddLinkProcedure(c,s.matfilter,3,4,s.lcheck)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	c:EnableReviveLimit()

	-- 魔陷区的表侧表示炎属性怪兽当作连接素材 (额外素材补充)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetValue(s.matval)
	c:RegisterEffect(e1)

	-- 召唤誓约限制：把这张卡连接召唤的回合，自己不是炎属性怪兽不能召唤·特殊召唤（完全对齐 c23600108）
	local e1_2=Effect.CreateEffect(c)
	e1_2:SetType(EFFECT_TYPE_SINGLE)
	e1_2:SetCode(EFFECT_SPSUMMON_COST)
	e1_2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1_2:SetCost(s.spcost)
	e1_2:SetOperation(s.spcop)
	c:RegisterEffect(e1_2)

	-- ①：连接召唤的这张卡不会被战斗·效果破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(s.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e2_eff=e2:Clone()
	e2_eff:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2_eff)

	-- ②：这张卡的攻击力上升自己场上·墓地的「创炎」连接怪兽数量×200
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)

	-- ③：魔陷区表侧怪兽任意送墓，本回合获得贯通伤害与多次攻击
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.atkcost)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)

	-- ④：从魔法与陷阱区域特殊召唤的场合才能发动，战阶封锁对方效果发动
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCountLimit(1,id+o*100)
	e5:SetCondition(s.actcon)
	e5:SetOperation(s.actop)
	c:RegisterEffect(e5)

	-- 全局计数注册：监听全回合非炎属性怪兽的召唤·特殊召唤
	Duel.AddCustomActivityCounter(id,ACTIVITY_SUMMON,s.counterfilter)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end

function s.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end

-- ==================== 连接召唤素材与组检查（严格对齐 c23600108） ====================
function s.matfilter(c,lc,sumtype,tp)
	if c:IsLocation(LOCATION_MZONE) then
		return c:IsSetCard(SET_CHOUEN,lc,sumtype,tp)
	elseif c:IsLocation(LOCATION_SZONE) then
		-- 【关键修复 1】：使用 GetOriginalType 位运算识别原本怪兽种类
		return c:IsFaceup() and (c:IsAttribute(ATTRIBUTE_FIRE,lc,sumtype,tp) or c:GetOriginalAttribute()==ATTRIBUTE_FIRE)
			and (c:GetOriginalType()&TYPE_MONSTER)~=0
	end
	return false
end

function s.chkfilter(c,lc,tp)
	return c:IsSetCard(SET_CHOUEN,lc,SUMMON_TYPE_LINK,tp) or c:IsOriginalSetCard(SET_CHOUEN)
end

function s.lcheck(g,lc,tp)
	-- 要求至少有3只「创炎」怪兽
	return g:FilterCount(s.chkfilter,nil,lc,tp)>=3
end

function s.matval(e,lc,mg,c,tp)
	if e:GetHandler()~=lc then return false,nil end
	-- 【关键修复 2】：规范的素材合法性回传
	return c:IsFaceup() and (c:IsAttribute(ATTRIBUTE_FIRE,lc,SUMMON_TYPE_LINK,tp) or c:GetOriginalAttribute()==ATTRIBUTE_FIRE)
		and (c:GetOriginalType()&TYPE_MONSTER)~=0, true
end

-- ==================== 召唤誓约限制（对齐 c23600108） ====================
function s.spcost(e,c,tp)
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SUMMON)==0
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
end

function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_FIRE)
end

function s.spcop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e2,tp)
end

-- ==================== ① 效果：抗性 ====================
function s.indcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

-- ==================== ② 效果：动态攻击力（【报错彻底解决】） ====================
function s.atkfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and c:IsSetCard(SET_CHOUEN) and c:IsType(TYPE_LINK)
end

function s.atkval(e,c)
	-- 【关键修复 3】：改用 e:GetHandlerPlayer()，彻底防止 c 为空引发报错
	local tp=e:GetHandlerPlayer()
	return Duel.GetMatchingGroupCount(s.atkfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)*200
end

-- ==================== ③ 效果：魔陷区怪兽送墓加攻/贯通 ====================
function s.costfilter(c)
	-- 【关键修复 4】：魔陷区怪兽送墓同样使用原本种类判断
	return c:IsFaceup() and (c:GetOriginalType()&TYPE_MONSTER)~=0 and c:IsAbleToGraveAsCost()
end

function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_SZONE,0,nil)
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:Select(tp,1,#g,nil)
	local ct=Duel.SendtoGrave(sg,REASON_COST)
	e:SetLabel(ct)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local ct=e:GetLabel()
	if ct<=0 then return end

	-- 获得贯通战斗伤害
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)

	-- 获得额外攻击次数（总攻击次数为 ct + 1）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(ct)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
end

-- ==================== ④ 效果：战阶封锁 ====================
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end

function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	-- 【关键修复 5】：阶段判定由 Condition 承载，SetValue 设为常数 1
	e1:SetCondition(s.accon)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.accon(e)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end