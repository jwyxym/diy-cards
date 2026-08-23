-- 虚空猎命·天蝎座 (ID: 23600048)
local s,id,o=GetID()
function s.initial_effect(c)
	-- 超量召唤手续：机械族·暗属性9星怪兽×2只以上
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,s.mfilter,9,2,nil,nil,99)

	-- ①：这张卡1回合只有1次不会被战斗·效果破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(s.indval)
	c:RegisterEffect(e1)

	-- ②：自己·对方回合，取除1个超量素材，以对方场上1只特召怪兽为对象：额外特召需支付900基本分
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_SUMMON+TIMING_SPSUMMON+TIMING_FLIPSUMMON+TIMING_END_PHASE)
	e2:SetCountLimit(1,id) -- ②效果 HOPT
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	-- ③：超量召唤的这张卡因对方从场上离开的场合，以墓地·除外的1张「转阶魔法」速攻魔法为对象：在场上盖放（当回合可发动）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCountLimit(1,id+o*100) -- ③效果 HOPT
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end

-- 超量素材过滤：机械族·暗属性
function s.mfilter(c,xyzc)
	return c:IsRace(RACE_MACHINE,xyzc) and c:IsAttribute(ATTRIBUTE_DARK,xyzc)
end

-- ①效果：战斗与效果抗破判定
function s.indval(e,re,r,rp)
	return r&(REASON_BATTLE+REASON_EFFECT)~=0
end

-- ②效果 Cost / Target / Operation
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		local c=e:GetHandler()

		-- 【第一层：规则特召拦截】若不足 900 LP 则直接禁止从额外特召
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_COST)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1) -- 严格作用于对方玩家
		e1:SetLabelObject(tc)
		e1:SetCondition(s.costcon)
		e1:SetCost(s.costchk)
		Duel.RegisterEffect(e1,tp)

		-- 【第二层：特召成功强制扣血】从额外特召出场时强制扣除 900 LP（支持规则特召与效果特召）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		e2:SetLabelObject(tc)
		e2:SetCondition(s.paycon)
		e2:SetOperation(s.payop)
		Duel.RegisterEffect(e2,tp)
	end
end

-- 目标怪兽存活与在场状态校验（一旦离场或变里侧，效果立即注销）
function s.costcon(e)
	local tc=e:GetLabelObject()
	if not (tc and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup()) then
		e:Reset()
		return false
	end
	return true
end
function s.costchk(e,te_or_c,tp)
	if te_or_c and te_or_c:IsLocation(LOCATION_EXTRA) then
		return Duel.CheckLPCost(tp,900)
	end
	return true
end

-- 扣血触发条件：只要从额外卡组特召成功，且目标怪兽在场
function s.exspfilter(c,tp)
	return c:IsControler(tp) and (c:IsSummonLocation(LOCATION_EXTRA) or c:IsPreviousLocation(LOCATION_EXTRA))
end
function s.paycon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not (tc and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup()) then
		e:Reset()
		return false
	end
	return eg:IsExists(s.exspfilter,1,nil,1-tp)
end
function s.payop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(1-tp,900)
	Duel.Hint(HINT_CARD,0,id)
end

-- ③效果 Condition / Target / Operation
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_XYZ)
		and c:IsPreviousControler(tp) and rp==1-tp
end
function s.setfilter(c)
	return c:IsSetCard(0x95) and c:IsType(TYPE_QUICKPLAY) and c:IsSSetable()
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.setfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and (tc:IsLocation(LOCATION_GRAVE) or tc:IsFaceup()) and Duel.SSet(tp,tc)>0 then
		-- 可以在盖放的回合发动
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end