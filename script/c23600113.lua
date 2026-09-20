-- 创炎之形-异类分圆 (ID: 23600113)
local s,id,o=GetID()
local SET_CHOUEN=0xd85 -- 「创炎」字段

function s.initial_effect(c)
	-- 永续魔法卡发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- ①：起动效果（自己主阶段在场上发动）：把手卡1只怪兽展示回到卡组底，手卡·卡组把同等级1只「创炎」怪兽当作永续魔法放置
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)

	-- ②：起动效果（自己主阶段在场上发动）：送墓魔陷区1张炎属性怪兽卡发动。本回合连接召唤「创炎」时，魔陷区1张永续魔法卡可当作「创炎」炎属性1星怪兽使用
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+o*100)
	e2:SetCost(s.cost2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)

	-- 全局全回合召唤动作监听（发动的回合非炎属性怪兽不可召唤·特殊召唤）
	if not s.global_check then
		s.global_check=true
		Duel.AddCustomActivityCounter(id,ACTIVITY_SUMMON,s.counterfilter)
		Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
	end
end

-- 召唤活动计数器：仅通过炎属性怪兽
function s.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end

-- 注册发动的回合全回合炎属性自肃
function s.reg_oath(e,tp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,target_p,se)
	return not c:IsAttribute(ATTRIBUTE_FIRE)
end

-- ==================== ① 效果：展示回底与放置（主阶段起动） ====================
function s.rvfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:GetLevel()>0 and not c:IsPublic()
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,c:GetLevel())
end

function s.plfilter(c,lv)
	return c:IsSetCard(SET_CHOUEN) and c:IsType(TYPE_MONSTER) and c:IsLevel(lv) and not c:IsForbidden()
end

function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SUMMON)==0
			and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.rvfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.rvfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	local tc=g:GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	Duel.ShuffleHand(tp)
	tc:CreateEffectRelation(e)
	e:SetLabelObject(tc)
	e:SetLabel(tc:GetLevel())
	s.reg_oath(e,tp)
end

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local lv=e:GetLabel()
	if tc and tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_HAND) then
		-- 回到卡组最下面 (seq = 1)
		if Duel.SendtoDeck(tc,nil,1,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK) then
			if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local g=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,lv)
			local sc=g:GetFirst()
			if sc and Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetCode(EFFECT_CHANGE_TYPE)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
				e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
				sc:RegisterEffect(e1)
			end
		end
	end
end

-- ==================== ② 效果：永续魔法当作「创炎」炎属性1星怪兽连接素材（主阶段起动） ====================
function s.cfilter(c)
	return c:IsFaceup() and (c:GetOriginalType()&TYPE_MONSTER)~=0
		and (c:IsAttribute(ATTRIBUTE_FIRE) or (c:GetOriginalAttribute()&ATTRIBUTE_FIRE)~=0)
		and c:IsAbleToGraveAsCost()
end

function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SUMMON)==0
			and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
	s.reg_oath(e,tp)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	
	-- 1. 允许魔陷区表侧永续魔法作为连接素材（解除自锁，回传 true, true）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetTarget(s.matsztarget)
	e1:SetValue(s.matval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	-- 2. 赋予怪兽种类（TYPE_MONSTER + TYPE_EFFECT）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetTarget(s.matsztarget)
	e2:SetValue(TYPE_MONSTER+TYPE_EFFECT)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)

	-- 3. 赋予「创炎」字段（0xd85）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_ADD_SETCODE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetTarget(s.matsztarget)
	e3:SetValue(SET_CHOUEN)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)

	-- 4. 赋予炎属性
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_ADD_ATTRIBUTE)
	e4:SetTargetRange(LOCATION_SZONE,0)
	e4:SetTarget(s.matsztarget)
	e4:SetValue(ATTRIBUTE_FIRE)
	e4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)

	-- 5. 赋予等级1
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetCode(EFFECT_CHANGE_LEVEL)
	e5:SetTargetRange(LOCATION_SZONE,0)
	e5:SetTarget(s.matsztarget)
	e5:SetValue(1)
	e5:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e5,tp)
end

-- 魔陷区表侧表示永续魔法卡过滤
function s.matsztarget(e,c)
	return c:IsFaceup() and c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_SPELL)
end

-- 限制仅在连接召唤「创炎」怪兽时适用，解除自锁
function s.matval(e,lc,mg,c,tp)
	if not (lc:IsSetCard(SET_CHOUEN) and lc:IsType(TYPE_LINK)) then return false, false end
	return true, true
end