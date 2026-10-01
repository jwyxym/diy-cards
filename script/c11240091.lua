-- 永夜的信矢 (ID: 11240090)
local s,id,o=GetID()
local SET_YONGYE=0xb92 -- 「永夜」字段

function s.initial_effect(c)
	-- ①：双方主要阶段，展示手卡1张「永夜」卡特召自身。确认的速攻/陷阱本回合可手发且持续公开
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)

	-- ②：召唤·特殊召唤的场合，二选一适用
	-- ●手卡特召「永夜」怪兽，那之后可回收墓地·除外不同名怪兽
	-- ●墓地·除外特召「永夜」怪兽（融合怪兽效果无效）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o*100)
	e2:SetTarget(s.efftg2)
	e2:SetOperation(s.effop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end

-- ==================== ① 效果逻辑 ====================

function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end

function s.cfilter1(c)
	return c:IsSetCard(SET_YONGYE) and not c:IsPublic()
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_HAND,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 1. 选自身手卡1张「永夜」卡给对方确认
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end

	Duel.ConfirmCards(1-tp,tc)

	-- 2. 这张卡从手卡特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 3. 若确认的是速攻魔法卡或陷阱卡，赋予本回合手发许可，且持续公开至回合结束
		local is_qp=(tc:IsType(TYPE_QUICKPLAY) and tc:IsType(TYPE_SPELL))
		local is_trap=tc:IsType(TYPE_TRAP)
		if is_qp or is_trap then
			-- 持续公开
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_PUBLIC)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)

			-- 陷阱卡手发许可
			if is_trap then
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e2)
			end

			-- 速攻魔法对方回合手发许可（自己的回合原生支持手发，对方回合赋予手发能力）
			if is_qp then
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end

-- ==================== ② 效果逻辑 ====================

-- 手卡特召过滤：「永夜」怪兽
function s.spfilter_hand(c,e,tp)
	return c:IsSetCard(SET_YONGYE) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- 墓地/除外特召过滤：「永夜」怪兽
function s.spfilter_gy(c,e,tp)
	return c:IsSetCard(SET_YONGYE) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end

-- 墓地/除外回收过滤（不同名怪兽）
function s.thfilter2(c,code)
	return c:IsSetCard(SET_YONGYE) and c:IsType(TYPE_MONSTER) and not c:IsCode(code) and c:IsAbleToHand()
		and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end

function s.efftg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local can_sp_hand=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter_hand,tp,LOCATION_HAND,0,1,nil,e,tp)
	local can_sp_gy=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter_gy,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)

	if chk==0 then return can_sp_hand or can_sp_gy end

	local op=0
	if can_sp_hand and can_sp_gy then
		op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
	elseif can_sp_hand then
		op=Duel.SelectOption(tp,aux.Stringid(id,3))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,4))+1
	end
	e:SetLabel(op)

	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	end
end

function s.effop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local op=e:GetLabel()

	if op==0 then
		-- 分支 1：手卡特召「永夜」怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter_hand,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- 那之后，可以把墓地·除外1只卡名不同的「永夜」怪兽加入手卡
			local th_g=Duel.GetMatchingGroup(s.thfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,tc:GetCode())
			if #th_g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local sg=th_g:Select(tp,1,1,nil)
				if #sg>0 then
					Duel.SendtoHand(sg,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,sg)
				end
			end
		end
	else
		-- 分支 2：墓地·除外特召「永夜」怪兽（融合怪兽效果无效）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter_gy),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
			-- 如果特召的是融合怪兽，效果无效化
			if tc:IsType(TYPE_FUSION) then
				local c=e:GetHandler()
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
		end
	end
end