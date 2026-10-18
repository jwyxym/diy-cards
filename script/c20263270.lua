-- 王家魔族开始！ (ID: 20263270)
local s,id,o=GetID()
local SET_WANG_JIA=0x321

function s.initial_effect(c)
	-- 发动与额外自肃
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- 注册全回合额外卡组特殊召唤行为计数（自肃前置检测）
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end

-- ==================== 额外卡组誓约过滤 ====================
function s.counterfilter(c)
	return not c:IsLocation(LOCATION_EXTRA)
end

function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end

-- ==================== 发动代价（800的倍数）与额外自肃 ====================
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lp=Duel.GetLP(tp)
	local max_ct=math.floor((lp-1)/800)
	if chk==0 then
		return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
			and max_ct>0
	end

	local t={}
	for i=1,max_ct do
		table.insert(t,i*800)
	end
	local pay=Duel.AnnounceNumber(tp,table.unpack(t))
	Duel.PayLPCost(tp,pay)
	-- 记录购买的召唤增加量
	e:SetLabel(pay//800)

	-- 发动的回合，自己不能从额外卡组特殊召唤怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

-- ==================== 条件抗性与目标检测 ====================
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>=3 then
		e:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISEFFECT)
	else
		e:SetProperty(0)
	end
end

-- ==================== 结算：对齐《连锁召唤》突破底层槽位限制 ====================
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if not ct or ct<=0 then return end

	-- 1. 采用官方《连锁召唤》唯一能支持多重通召的底层核心：EFFECT_SET_SUMMON_COUNT_LIMIT
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 原有上限（1）+ 购买次数（ct）
	e1:SetValue(1+ct)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	-- 2. 状态提示与本家召唤约束（确保超出的通常召唤次数只能召唤「王家魔族」）
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.sumlimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end

-- 当回合的基础通常召唤次数（第1次）允许召唤任意怪兽；超过1次后只能召唤「王家魔族」
function s.sumlimit(e,c)
	local tp=e:GetHandlerPlayer()
	local act_ct=Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)
	-- 若本回合已经进行过 1 次通常召唤，后续的所有召唤强制限定为「王家魔族」
	return act_ct>=1 and not c:IsSetCard(SET_WANG_JIA)
end