-- 绝命虚空·巡游 (ID: 23600047)
local s,id,o=GetID()
function s.initial_effect(c)
	-- ①：把这张卡从手卡丢弃才能发动。从手卡把1只机械族·暗属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id) -- ①效果 HOPT
	e1:SetCost(s.spcost1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)

	-- ②：三向诱发特召自身，并使场上1只暗机械可作为9星超量素材
	-- ②-1：对方连锁自己的机械族·暗属性怪兽效果发动
	local e2_1=Effect.CreateEffect(c)
	e2_1:SetDescription(aux.Stringid(id,1))
	e2_1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2_1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2_1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2_1:SetCode(EVENT_CHAINING)
	e2_1:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e2_1:SetCountLimit(1,id+o*100) -- ②效果 HOPT
	e2_1:SetCondition(s.spcon_chain)
	e2_1:SetCost(s.oath_cost)
	e2_1:SetTarget(s.sptg2)
	e2_1:SetOperation(s.spop2)
	c:RegisterEffect(e2_1)

	-- ②-2：自己场上的机械族·暗属性怪兽成为效果的对象
	local e2_2=e2_1:Clone()
	e2_2:SetCode(EVENT_BECOME_TARGET)
	e2_2:SetCondition(s.spcon_target)
	c:RegisterEffect(e2_2)

	-- ②-3：这张卡被除外的场合
	local e2_3=e2_1:Clone()
	e2_3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2_3:SetCode(EVENT_REMOVE)
	e2_3:SetRange(LOCATION_REMOVED)
	e2_3:SetCondition(s.spcon_remove)
	c:RegisterEffect(e2_3)

	-- 全局召唤/特召监听（整回合自肃检查）
	if not s.global_check then
		s.global_check=true
		Duel.AddCustomActivityCounter(id,ACTIVITY_SUMMON,s.counterfilter)
		Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
	end
end

-- 全局自肃计数过滤：只允许机械族
function s.counterfilter(c)
	return c:IsRace(RACE_MACHINE)
end
function s.oath_check(e,tp)
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SUMMON)==0
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
end
function s.reg_oath(e,tp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
end
function s.splimit(e,c)
	return not c:IsRace(RACE_MACHINE)
end

-- ①效果：手卡丢弃特召
function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() and s.oath_check(e,tp) end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
	s.reg_oath(e,tp)
end
function s.spfilter1(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- ②效果：三大触发 Condition
-- 触发 1：对方连锁自己的机械族·暗属性怪兽效果发动
function s.spcon_chain(e,tp,eg,ep,ev,re,r,rp)
	if ep~=1-tp or ev<=1 then return false end
	local te=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT)
	local tgp=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_PLAYER)
	local tc=te:GetHandler()
	return tgp==tp and te:IsActiveType(TYPE_MONSTER) and tc:IsRace(RACE_MACHINE) and tc:IsAttribute(ATTRIBUTE_DARK)
end
-- 触发 2：自己场上的机械族·暗属性怪兽成为效果的对象
function s.tgfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
		and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.spcon_target(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.tgfilter,1,nil,tp)
end
-- 触发 3：这张卡被除外的场合
function s.spcon_remove(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()
end

-- ②效果 Cost / Target / Operation
function s.oath_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.oath_check(e,tp) end
	s.reg_oath(e,tp)
end
function s.target_filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.target_filter(chkc) end
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
			and Duel.IsExistingTarget(s.target_filter,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.target_filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			-- 这个回合，可以作为9星怪兽成为超量素材
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_XYZ_LEVEL)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(s.xyzlv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
function s.xyzlv(e,c,rc)
	local lv=c:GetLevel()
	return 9<<16 | lv
end