-- 混沌No.8 纹章君主 (ID: 98765405)
local s,id,o=GetID()
function s.initial_effect(c)
	-- 关联卡片 Passcode（不明: 77571455）
	aux.AddCodeList(c,77571455)

	-- Xyz 召唤手续：念动力族「No.」超量怪兽×2，也可重叠在卡名为「不明」的超量怪兽上重叠召唤（1回合1次）
	aux.AddXyzProcedureLevelFree(c,s.matfilter,nil,2,2,s.ovfilter,aux.Stringid(id,0),s.xyzop)
	c:EnableReviveLimit()

	-- ①：只要这张卡在怪兽区域存在，这张卡不会被战斗·效果破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)

	-- ②：自己·对方回合1次，把这张卡的1个超量素材取除，宣言1个卡名才能发动。直到下个自己回合结束时，原本卡名与宣言的卡相同的卡卡名当作「不明」使用，效果不适用。宣言的卡是怪兽的场合，对方不能用与那张卡原本卡名相同的怪兽进行攻击宣言。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	-- 使用全平台兼容的基础时点宏组合
	e3:SetHintTiming(0,TIMING_SUMMON+TIMING_SPSUMMON+TIMING_FLIPSUMMON+TIMING_MAIN_END+TIMING_END_PHASE)
	e3:SetCountLimit(1) -- SOPT (单卡1回合1次)
	e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end

-- 编号注册：CNo.8
aux.xyz_number[id]=8

-- 正规超量素材过滤：严格锁定【念动力族】+【「No.」字段】+【超量怪兽】
function s.matfilter(c,xyzc)
	return c:IsFaceup()
		and c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ)
		and c:IsRace(RACE_PSYCHO,xyzc,SUMMON_TYPE_XYZ)
		and c:IsSetCard(0x48,xyzc,SUMMON_TYPE_XYZ)
end

-- 重叠超量召唤条件：仅允许卡名当前为「不明」(77571455) 的超量怪兽
function s.ovfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsCode(77571455)
end

-- 重叠召唤 1 回合 1 次限制 Flag 标记
function s.xyzop(e,tp,chk,mc)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

-- ==================== ② 效果：宣言卡名改名「不明」与效果不适用 ====================
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local rct=Duel.GetTurnPlayer()==tp and 2 or 1
	local reset_flag=RESET_PHASE+PHASE_END+RESET_SELF_TURN

	-- 1. 场上原本卡名与宣言卡名相同的卡，卡名当作「不明」(77571455) 使用
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e1:SetTarget(s.nametg)
	e1:SetValue(77571455)
	e1:SetLabel(ac)
	e1:SetReset(reset_flag,rct)
	Duel.RegisterEffect(e1,tp)

	-- 2. 封锁效果发动（全区域禁止发动原本卡名为 ac 的卡的效果）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetTargetRange(1,1)
	e2:SetValue(s.aclimit)
	e2:SetLabel(ac)
	e2:SetReset(reset_flag,rct)
	Duel.RegisterEffect(e2,tp)

	-- 3. 场上现有卡效果无效
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e3:SetTarget(s.nametg)
	e3:SetLabel(ac)
	e3:SetReset(reset_flag,rct)
	Duel.RegisterEffect(e3,tp)

	-- 4. 连锁处理时无效（拦截手卡/墓地发动的效果在结算时生效）
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetCondition(s.discon)
	e4:SetOperation(s.disop)
	e4:SetLabel(ac)
	e4:SetReset(reset_flag,rct)
	Duel.RegisterEffect(e4,tp)

	-- 5. 宣言卡片为怪兽时，对方不能用与那张卡原本卡名相同的怪兽进行攻击宣言
	-- 修正 1：改用原生 CreateToken 实例化对象判断怪兽类型，彻底清除 115 行报错
	local token=Duel.CreateToken(tp,ac)
	if token and token:IsType(TYPE_MONSTER) then
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_FIELD)
		-- 修正 2：使用标准的 EFFECT_CANNOT_ATTACK 对齐怪兽区 TargetRange(0, LOCATION_MZONE)
		e5:SetCode(EFFECT_CANNOT_ATTACK)
		e5:SetTargetRange(0,LOCATION_MZONE)
		e5:SetTarget(s.atktg)
		e5:SetLabel(ac)
		e5:SetReset(reset_flag,rct)
		Duel.RegisterEffect(e5,tp)
	end
end

function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return rc and rc:IsOriginalCodeRule(e:GetLabel())
end

function s.nametg(e,c)
	return c:IsOriginalCodeRule(e:GetLabel())
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc and rc:IsOriginalCodeRule(e:GetLabel())
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

function s.atktg(e,c)
	return c:IsOriginalCodeRule(e:GetLabel())
end