-- 创炎之构-异倾六分 (ID: 23600108)
local s,id,o=GetID()
function s.initial_effect(c)
	-- link summon：「创炎」怪兽 2 只以上 (LINK-3)
	local e0=aux.AddLinkProcedure(c,s.matfilter,2,3,s.lcheck)
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

	-- 召唤誓约限制：把这张卡连接召唤的回合，自己不是炎属性怪兽不能召唤·特殊召唤
	local e1_2=Effect.CreateEffect(c)
	e1_2:SetType(EFFECT_TYPE_SINGLE)
	e1_2:SetCode(EFFECT_SPSUMMON_COST)
	e1_2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1_2:SetCost(s.spcost)
	e1_2:SetOperation(s.spcop)
	c:RegisterEffect(e1_2)

	-- ①：这张卡不会成为对方的效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)

	-- ②：场上有怪兽召唤·特召的场合，以场上 1 只怪兽为对象才能发动。当作永续魔法卡使用在原本持有者的魔陷区放置
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*100) -- 遵循规则 1.6，使用 id+o*100 防撞车
	e3:SetTarget(s.tftg2)
	e3:SetOperation(s.tfop2)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)

	-- ③：从魔陷区特殊召唤的场合才能发动。选场上·墓地 1 只怪兽当作永续魔法卡使用在原本持有者的魔陷区放置
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_GRAVE_ACTION)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCountLimit(1,id+o*200) -- 遵循规则 1.6，使用 id+o*200 防撞车
	e5:SetCondition(s.tfcon3)
	e5:SetTarget(s.tftg3)
	e5:SetOperation(s.tfop3)
	c:RegisterEffect(e5)

	-- 全局检测：监听玩家召唤·特召非炎属性怪兽的行为（参考 c23600107）
	Duel.AddCustomActivityCounter(id,ACTIVITY_SUMMON,s.counterfilter)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end

function s.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end

-- ==================== 连接召唤素材与组检查 ====================
function s.matfilter(c,lc,sumtype,tp)
	if c:IsLocation(LOCATION_MZONE) then
		return c:IsSetCard(0xd85,lc,sumtype,tp)
	elseif c:IsLocation(LOCATION_SZONE) then
		return c:IsFaceup() and (c:IsAttribute(ATTRIBUTE_FIRE,lc,sumtype,tp) or c:GetOriginalAttribute()==ATTRIBUTE_FIRE)
			and (c:GetOriginalType()&TYPE_MONSTER)~=0
	end
	return false
end

function s.chkfilter(c,lc,tp)
	return c:IsSetCard(0xd85,lc,SUMMON_TYPE_LINK,tp) or c:IsOriginalSetCard(0xd85)
end

function s.lcheck(g,lc,tp)
	return g:FilterCount(s.chkfilter,nil,lc,tp)>=2
end

function s.matval(e,lc,mg,c,tp)
	if e:GetHandler()~=lc then return false,nil end
	-- 修正：使用原生 c:GetOriginalType() 位运算，替代不存在的 IsOriginalType 函数
	return c:IsFaceup() and (c:IsAttribute(ATTRIBUTE_FIRE,lc,SUMMON_TYPE_LINK,tp) or c:GetOriginalAttribute()==ATTRIBUTE_FIRE)
		and (c:GetOriginalType()&TYPE_MONSTER)~=0, true
end

-- ==================== 召唤誓约限制 ====================
function s.spcost(e,c,tp)
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SUMMON)==0
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
end

function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_FIRE)
end

function s.spcop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e2,tp)
end

-- ==================== ② 效果：场上怪兽放置为永续魔法 ====================
function s.tffilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsOnField()
		and Duel.GetLocationCount(c:GetOwner(),LOCATION_SZONE)>0
		and not c:IsForbidden()
end

function s.tftg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.tffilter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tffilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tffilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end

function s.tfop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and not tc:IsImmuneToEffect(e) then
		local p=tc:GetOwner()
		if Duel.GetLocationCount(p,LOCATION_SZONE)<=0 then return end
		if Duel.MoveToField(tc,tp,p,LOCATION_SZONE,POS_FACEUP,true) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
		end
	end
end

-- ==================== ③ 效果：从魔陷特召时选场上/墓地怪兽放置为永续魔法 ====================
function s.tfcon3(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end

function s.tffilter3(c)
	return c:IsType(TYPE_MONSTER)
		and (c:IsLocation(LOCATION_MZONE) or c:IsLocation(LOCATION_GRAVE))
		and Duel.GetLocationCount(c:GetOwner(),LOCATION_SZONE)>0
		and not c:IsForbidden()
end

function s.tftg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tffilter3,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
end

function s.tfop3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tffilter3),tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local p=tc:GetOwner()
		if Duel.GetLocationCount(p,LOCATION_SZONE)<=0 then return end
		if Duel.MoveToField(tc,tp,p,LOCATION_SZONE,POS_FACEUP,true) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
		end
	end
end