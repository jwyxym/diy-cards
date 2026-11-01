--馆长拉法姆
local s,id=GetID()
function s.initial_effect(c)
	-- 特殊上级召唤手续（参考天帝アイテール写法）
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,3))
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SUMMON_PROC)
	e0:SetCondition(s.otcon)
	e0:SetOperation(s.otop)
	e0:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e0)

	-- ① 上级召唤成功时必发
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)

	-- ② 对方主要阶段，除外墓地拉法姆魔陷进行上级召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(s.spcon2)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)

	-- 自肃计数器
	Duel.AddCustomActivityCounter(id+300,ACTIVITY_SUMMON,s.counterfilter)
	Duel.AddCustomActivityCounter(id+300,ACTIVITY_SPSUMMON,s.counterfilter)
end

-- 自肃
function s.counterfilter(c) return c:IsSetCard(0x0cf0) end
function s.CheckBond(tp)
	return Duel.GetCustomActivityCount(id+300,tp,ACTIVITY_SUMMON)==0
		and Duel.GetCustomActivityCount(id+300,tp,ACTIVITY_SPSUMMON)==0
end
function s.RegisterSelfBond(tp,c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.sumlimit)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTarget(s.splimit)
	Duel.RegisterEffect(e2,tp)
end
function s.sumlimit(e,c) return not c:IsSetCard(0x0cf0) end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se) return not c:IsSetCard(0x0cf0) end

-- 上级召唤手续
function s.releasefilter(c)
	return c:IsSetCard(0x0cf0) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end

function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	if minc>2 then return false end
	local g_opp=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,LOCATION_MZONE,nil,REASON_SUMMON)
	local g_own=Duel.GetMatchingGroup(s.releasefilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	return g_opp:GetCount()>=1 and g_own:GetCount()>=1
end

function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	local g_opp=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,LOCATION_MZONE,nil,REASON_SUMMON)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local opp=g_opp:Select(tp,1,1,nil)
	local g_own=Duel.GetMatchingGroup(s.releasefilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local own=g_own:Select(tp,1,1,nil)

	local sg=Group.CreateGroup()
	sg:Merge(opp)
	sg:Merge(own)
	c:SetMaterial(sg)

	local fg=sg:Filter(Card.IsLocation,nil,LOCATION_MZONE)
	if fg:GetCount()>0 then
		Duel.Release(fg,REASON_SUMMON+REASON_MATERIAL)
	end
	local hg=sg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if hg:GetCount()>0 then
		Duel.SendtoGrave(hg,REASON_RELEASE+REASON_MATERIAL)
	end
end

-- ① 效果
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_SZONE,nil,TYPE_SPELL+TYPE_TRAP)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.thfilter(c)
	return c:IsSetCard(0x0cf0) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	s.RegisterSelfBond(tp,e:GetHandler())
	-- 对方场上没有魔陷时，不处理后续
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_SZONE,nil,TYPE_SPELL+TYPE_TRAP)
	if #g==0 then return end
	-- 破坏并检查是否实际破坏成功
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct==0 then return end  -- 未成功破坏任何卡，不处理检索
	-- 可选检索
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #sg>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end

-- ② 效果
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()~=tp
		and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
		and Duel.GetFlagEffect(tp,id+200)==0
		and s.CheckBond(tp)
end
function s.spcostfilter(c)
	return c:IsSetCard(0x0cf0) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE+PHASE_END,0,1)
	s.RegisterSelfBond(tp,e:GetHandler())
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsSummonable(true,nil,2)
	end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,c,1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Summon(tp,c,true,nil)
	end
end