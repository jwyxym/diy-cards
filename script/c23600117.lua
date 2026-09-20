-- 创炎世火-谢尔宾斯基 (ID: 23600117)
local s,id,o=GetID()
local SET_CHOUEN=0xd85 -- 「创炎」字段

function s.initial_effect(c)
	-- 连接召唤手续：包含连接怪兽的「创炎」怪兽4只以上 (LINK-5)
	local e0=aux.AddLinkProcedure(c,s.matfilter,4,5,s.lcheck)
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

	-- ①：对方不能对应自己的「创炎」魔法·陷阱卡的效果的发动把效果发动
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.chainop)
	c:RegisterEffect(e2)

	-- ②：自己·对方回合，送墓魔陷区表侧表示卡发动，3选1适用
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_SUMMON+TIMING_SPSUMMON+TIMING_MAIN_END+TIMING_END_PHASE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.cost2)
	e3:SetTarget(s.tg2)
	e3:SetOperation(s.op2)
	c:RegisterEffect(e3)

	-- ③：从魔法与陷阱区域特殊召唤的场合，这张卡不受「创炎」卡以外的卡效果影响
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetCondition(s.immcon)
	e4:SetValue(s.immval)
	c:RegisterEffect(e4)

	-- 全局计数注册：监听全回合非炎属性怪兽的召唤·特殊召唤
	Duel.AddCustomActivityCounter(id,ACTIVITY_SUMMON,s.counterfilter)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end

function s.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end

-- ==================== 连接召唤素材与组检查（严格对齐 c23600108 架构） ====================
function s.matfilter(c,lc,sumtype,tp)
	if c:IsLocation(LOCATION_MZONE) then
		return c:IsSetCard(SET_CHOUEN,lc,sumtype,tp)
	elseif c:IsLocation(LOCATION_SZONE) then
		-- 【关键修复 1】：使用 GetOriginalType 位运算识别怪兽原本种类，彻底解决魔陷区误判
		return c:IsFaceup() and (c:IsAttribute(ATTRIBUTE_FIRE,lc,sumtype,tp) or c:GetOriginalAttribute()==ATTRIBUTE_FIRE)
			and (c:GetOriginalType()&TYPE_MONSTER)~=0
	end
	return false
end

function s.chkfilter(c,lc,tp)
	return c:IsSetCard(SET_CHOUEN,lc,SUMMON_TYPE_LINK,tp) or c:IsOriginalSetCard(SET_CHOUEN)
end

function s.lcheck(g,lc,tp)
	-- 要求包含连接怪兽且至少有4只「创炎」怪兽
	return g:IsExists(Card.IsType,1,nil,TYPE_LINK) and g:FilterCount(s.chkfilter,nil,lc,tp)>=4
end

function s.matval(e,lc,mg,c,tp)
	if e:GetHandler()~=lc then return false,nil end
	-- 【关键修复 2】：与 c23600108 完全一致的素材合法性回传
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
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	Duel.RegisterEffect(e2,tp)
end

-- ==================== ① 效果：封锁对方连锁 ====================
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetHandler():IsSetCard(SET_CHOUEN) then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp
end

-- ==================== ② 效果：二速三选一 ====================
function s.costfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end

function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

function s.setfilter(c)
	return (c:IsLocation(LOCATION_DECK+LOCATION_GRAVE) or c:IsFaceup())
		and c:IsSetCard(SET_CHOUEN) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end

function s.plfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden()
		and Duel.GetLocationCount(c:GetOwner(),LOCATION_SZONE)>0
end

function s.spfilter(c,e,tp)
	return c:IsLocation(LOCATION_SZONE) and c:IsFaceup()
		and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS)
		and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
	local b3=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 or b3 end

	local ops={}
	local opval={}
	local off=1
	if b1 then
		ops[off]=aux.Stringid(id,0)
		opval[off]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(id,1)
		opval[off]=2
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(id,2)
		opval[off]=3
		off=off+1
	end

	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	e:SetLabel(sel)

	if sel==1 then
		e:SetCategory(CATEGORY_LEAVE_GRAVE)
	elseif sel==2 then
		e:SetCategory(CATEGORY_LEAVE_GRAVE)
	elseif sel==3 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
	end
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==1 then
		-- 分支 1：盖放「创炎」魔陷
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		if #g>0 then
			Duel.SSet(tp,g)
		end
	elseif sel==2 then
		-- 分支 2：场上·墓地怪兽当作永续魔法放置
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.plfilter),tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
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
	elseif sel==3 then
		-- 分支 3：特召魔陷区当作永续魔法的炎属性怪兽
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

-- ==================== ③ 效果：从魔陷特召全抗 ====================
function s.immcon(e)
	return e:GetHandler():IsSummonLocation(LOCATION_SZONE)
end
function s.immval(e,te)
	return not te:GetHandler():IsSetCard(SET_CHOUEN)
end