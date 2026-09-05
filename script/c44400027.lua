-- 魂零的葬歌奏者 (ID: 44400027)
local s,id,o=GetID()
function s.initial_effect(c)
	-- Link 召唤手续：「绮饿罗」(0x444) 怪兽或者融合怪兽 3 只
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.matfilter,3,3)

	-- 规则上当做「绮饿罗」卡使用
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x444)
	c:RegisterEffect(e0)

	-- ①：自己不能让这张卡在主要怪兽区域出现
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_MUST_USE_MZONE)
	e1:SetValue(0x600060) -- 仅允许额外怪兽区域 (EMZ)
	c:RegisterEffect(e1)

	local e1_2=Effect.CreateEffect(c)
	e1_2:SetType(EFFECT_TYPE_SINGLE)
	e1_2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1_2:SetCode(EFFECT_SELF_TOGRAVE)
	e1_2:SetRange(LOCATION_MZONE)
	e1_2:SetCondition(s.selfgcon)
	c:RegisterEffect(e1_2)

	-- ②：预创建赋予链接区怪兽的子效果实体
	-- 子效果 1：等级上升 2
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_SINGLE)
	ge1:SetCode(EFFECT_UPDATE_LEVEL)
	ge1:SetRange(LOCATION_MZONE)
	ge1:SetValue(2)

	-- 子效果 2：阶级上升 2
	local ge2=Effect.CreateEffect(c)
	ge2:SetType(EFFECT_TYPE_SINGLE)
	ge2:SetCode(EFFECT_UPDATE_RANK)
	ge2:SetRange(LOCATION_MZONE)
	ge2:SetValue(2)

	-- 子效果 3：魔法·陷阱卡效果发动时，该怪兽自身发动，攻击力下降 1000（同连锁各限 1 次）
	local ge3=Effect.CreateEffect(c)
	ge3:SetDescription(aux.Stringid(id,2))
	ge3:SetCategory(CATEGORY_ATKCHANGE)
	ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	ge3:SetCode(EVENT_CHAINING)
	ge3:SetRange(LOCATION_MZONE)
	ge3:SetCondition(s.chaincon)
	ge3:SetTarget(s.chaintg)
	ge3:SetOperation(s.chainop)

	-- 通过 GRANT 机制将上述效果赋予链接区怪兽
	local e2_1=Effect.CreateEffect(c)
	e2_1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2_1:SetRange(LOCATION_MZONE)
	e2_1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2_1:SetTarget(s.granttg)
	e2_1:SetLabelObject(ge1)
	c:RegisterEffect(e2_1)

	local e2_2=e2_1:Clone()
	e2_2:SetLabelObject(ge2)
	c:RegisterEffect(e2_2)

	local e2_3=e2_1:Clone()
	e2_3:SetLabelObject(ge3)
	c:RegisterEffect(e2_3)

	-- ③：自己・对方回合各 1 次。解放自己场上 1 只融合怪兽，选对方场上 1 张卡无效...
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END+TIMING_SUMMON+TIMING_SPSUMMON+TIMING_FLIPSUMMON+TIMING_END_PHASE)
	e3:SetCountLimit(1)
	e3:SetCost(s.discost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end

-- Link 素材过滤
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0x444) or c:IsType(TYPE_FUSION)
end

-- ① 效果：出现在主要怪兽区则自动送墓
function s.selfgcon(e)
	return e:GetHandler():GetSequence()<5
end

-- ② 效果：链接区目标筛选
function s.granttg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end

-- ② 获得效果：当魔法·陷阱卡或效果发动时，由该怪兽自身触发
function s.chaincon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and c:GetFlagEffect(id)==0
end

function s.chaintg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 在获得效果的怪兽身上注册同 1 连锁限 1 次标记
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,c,1,0,-1000)
end

function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 降低该怪兽自身 1000 点攻击力
		local e1=Effect.CreateEffect(e:GetOwner())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end

-- ③ 效果：解放融合怪兽无效 & 结束阶段特召
function s.costfilter(c)
	return c:IsType(TYPE_FUSION)
end

function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil) end
	local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil)
	local tc=g:GetFirst()
	e:SetLabel(tc:GetLevel()) -- 记录被解放怪兽在场上的等级
	Duel.Release(g,REASON_COST)
end

function s.disfilter(c)
	return c:IsFaceup() and not c:IsDisabled()
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	local g=Duel.SelectMatchingCard(tp,s.disfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=e1:Clone()
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc:RegisterEffect(e3)
		end
	end

	-- 注册结束阶段延时特召效果
	if lv>0 then
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetDescription(aux.Stringid(id,1))
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_PHASE+PHASE_END)
		e4:SetCountLimit(1)
		e4:SetLabel(lv)
		e4:SetReset(RESET_PHASE+PHASE_END,1)
		e4:SetOperation(s.spop)
		Duel.RegisterEffect(e4,tp)
	end
end

-- 结束阶段特召逻辑
function s.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x444) and c:IsType(TYPE_FUSION)
		and c:GetLevel()<lv and c:GetLevel()>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	e:Reset() -- 执行后立即重置，防止重复触发
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,lv)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,lv)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end