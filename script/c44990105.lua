--欢笑的姐妹
local s,id=GetID()
function s.initial_effect(c)
	-- 将此卡标记为“有「伊瑟拉」的卡名记述”
	aux.AddCodeList(c,44990100)

	-- ① 召唤·特殊召唤成功时效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

	-- ② 自己主要阶段效果
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.con2)
	e3:SetTarget(s.tg2)
	e3:SetOperation(s.op2)
	c:RegisterEffect(e3)

	-- ③ 超量素材等级可变效果
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_XYZ_LEVEL)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.xyzlv)
	e4:SetLabel(8)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetLabel(9)
	c:RegisterEffect(e5)

	-- ① 发动后特殊召唤限制（本回合非风属性不能特殊召唤）
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(1,0)
	e6:SetCondition(s.splimcon)
	e6:SetTarget(s.splimit)
	c:RegisterEffect(e6)
end

-- 检查是否有「伊瑟拉」卡名记述（兼容版）
function s.IsYseraCard(c)
	if aux.IsCodeListed then
		return aux.IsCodeListed(c,44990100)
	else
		return c:IsSetCard(0xcf1)
	end
end

-- ① 条件：一回合一次（标志 id）
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)==0
end

-- ① 目标检查：卡组有符合条件的魔陷，且魔陷区有空位
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local loc_avail = Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		if not loc_avail then return false end
		local g=Duel.GetMatchingGroup(s.stfilter,tp,LOCATION_DECK,0,nil)
		return #g>0
	end
end

-- ① 魔陷过滤器：有「伊瑟拉」记述的魔法·陷阱卡
function s.stfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and s.IsYseraCard(c) and c:IsSSetable()
end

-- ① 操作：从卡组选1张符合条件的魔陷盖放，并设置自肃和标志
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFlagEffect(tp,id)>0 then return end
	local g=Duel.GetMatchingGroup(s.stfilter,tp,LOCATION_DECK,0,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local sc=g:Select(tp,1,1,nil):GetFirst()
	if sc then
		Duel.SSet(tp,sc)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		-- 本回合非风属性不能特殊召唤的标志
		Duel.RegisterFlagEffect(tp,id+300,RESET_PHASE+PHASE_END,0,1)
	end
end

-- ② 条件：主要阶段 + 一回合一次（标志 id+100）
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+100)==0
end

-- ② 目标检查：手卡·墓地存在符合条件的龙族怪兽
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

-- ② 特殊召唤过滤器：有「伊瑟拉」记述的龙族怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and s.IsYseraCard(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ② 操作：选择并特殊召唤
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
	end
end

-- ③ 等级修改函数（参考深渊鲨）
function s.xyzlv(e,c,rc)
	if rc:IsSetCard(0xcf1) then
		return c:GetLevel() + 0x10000 * e:GetLabel()
	else
		return c:GetLevel()
	end
end

-- 特殊召唤限制条件：标志 id+300 存在时
function s.splimcon(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id+300)>0
end

-- 禁止非风属性特殊召唤
function s.splimit(e,c,tp,sumtp)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end