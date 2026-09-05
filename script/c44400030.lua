-- 宿忘之魂零 (ID: 44400025)
local s,id,o=GetID()
function s.initial_effect(c)
	-- 融合召唤手续：「绮饿罗」(0x444) 怪兽 × 2
	aux.AddFusionProcFunRep(c,s.matfilter,2,false)
	c:EnableReviveLimit()

	-- 记录关联卡名（绮饿罗堕变: 44400022）
	aux.AddCodeList(c,44400022)

	-- 规则上当做「绮饿罗」卡使用
	local e00=Effect.CreateEffect(c)
	e00:SetType(EFFECT_TYPE_SINGLE)
	e00:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e00:SetCode(EFFECT_ADD_SETCODE)
	e00:SetValue(0x444)
	c:RegisterEffect(e00)

	-- 特殊召唤限制：不能从额外卡组特殊召唤，除了「绮饿罗堕变」的效果
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)

	-- ①：只要这张卡在场上表侧表示存在，对方不能在同1条连锁上把已经发动过效果的卡以及同名卡的效果发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.actlimit)
	c:RegisterEffect(e1)

	-- ②：融合召唤的这张卡表侧表示存在的场合才有1次。双方在同1条连锁上把怪兽·魔法·陷阱卡的效果各发动过1次的场合才能发动...
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET) -- 场上表侧表示仅 1 次
	e2:SetCountLimit(1)
	e2:SetCondition(s.effcon)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)

	-- 全局监控：记录本回合发动过效果的卡名
	s.register_global_check(c)
end

-- 融合素材过滤：「绮饿罗」怪兽
function s.matfilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x444)
end

-- 特殊召唤限制判断（仅限制从额外卡组特召）
function s.splimit(e,se,sp,st)
	if not e:GetHandler():IsLocation(LOCATION_EXTRA) then return true end
	return se and se:GetHandler():IsCode(44400022)
end

-- ==================== ① 效果：同连锁禁止二次/同名发动 ====================
function s.actlimit(e,re,tp)
	local rc=re:GetHandler()
	if not rc then return false end
	local count=Duel.GetCurrentChain()
	if count==0 then return false end
	for i=1,count do
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		local code=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_CODE)
		if te then
			local tc=te:GetHandler()
			-- 同一张卡 或 同名卡 在当前同一连锁上已存在发动记录
			if tc==rc or rc:IsCode(code) then
				return true
			end
		end
	end
	return false
end

-- ==================== ② 效果：怪魔陷同连锁各1次后卡名效果无效 ====================
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsFaceup()) then return false end
	local count=Duel.GetCurrentChain()
	if count<3 then return false end
	local has_monster=false
	local has_spell=false
	local has_trap=false
	for i=1,count do
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		if te then
			if te:IsActiveType(TYPE_MONSTER) then has_monster=true end
			if te:IsActiveType(TYPE_SPELL) then has_spell=true end
			if te:IsActiveType(TYPE_TRAP) then has_trap=true end
		end
	end
	return has_monster and has_spell and has_trap
end

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return s.has_activated_codes()
	end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,0,0,0)
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
	if not s.has_activated_codes() then return end
	
	-- 循环宣言校验，确保玩家只能且必须宣言本回合发动过效果的卡名
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local code=Duel.AnnounceCard(tp)
	while not s.is_code_activated(code) do
		code=Duel.AnnounceCard(tp)
	end

	local c=e:GetHandler()

	-- 1. 场上卡片效果无效（EFFECT_DISABLE）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e1:SetTarget(s.distg)
	e1:SetLabel(code)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	-- 2. 场上发动效果无效（EFFECT_DISABLE_EFFECT）
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	Duel.RegisterEffect(e2,tp)

	-- 3. 连锁全区域效果无效（EFFECT_DISABLE_CHAIN，涵盖手卡/墓地/除外区发动）
	local e3=e1:Clone()
	e3:SetCode(EFFECT_DISABLE_CHAIN)
	e3:SetValue(s.chainval)
	Duel.RegisterEffect(e3,tp)

	-- 4. 使场上已存在的该卡名卡片当前连锁链无效化
	local g=Duel.GetMatchingGroup(s.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,code)
	for tc in aux.Next(g) do
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
	end
end

-- ==================== 全局卡名监控系统 ====================
if not s.activated_codes then
	s.activated_codes={}
end

function s.register_global_check(c)
	if s.global_check then return end
	s.global_check=true

	local ge1=Effect.GlobalEffect()
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetCode(EVENT_CHAINING)
	ge1:SetOperation(s.chain_reg_op)
	Duel.RegisterEffect(ge1,0)

	local ge2=Effect.GlobalEffect()
	ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	ge2:SetOperation(s.reset_reg_op)
	Duel.RegisterEffect(ge2,0)
end

function s.chain_reg_op(e,tp,eg,ep,ev,re,r,rp)
	if re then
		local rc=re:GetHandler()
		if rc then
			s.activated_codes[rc:GetCode()]=true
			s.activated_codes[rc:GetOriginalCode()]=true
			s.activated_codes[rc:GetOriginalCodeRule()]=true
		end
		local code=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CODE)
		if code then
			s.activated_codes[code]=true
		end
	end
end

function s.reset_reg_op(e,tp,eg,ep,ev,re,r,rp)
	s.activated_codes={}
end

function s.has_activated_codes()
	return next(s.activated_codes)~=nil
end

function s.is_code_activated(code)
	return s.activated_codes[code]==true
end

function s.distg(e,c)
	local code=e:GetLabel()
	return c:IsCode(code)
end

function s.chainval(e,re,rp)
	local code=e:GetLabel()
	return re:GetHandler():IsCode(code)
end

function s.disfilter(c,code)
	return c:IsCode(code) and c:IsFaceup() and not c:IsDisabled()
end