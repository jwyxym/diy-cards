-- 卡密：12210001
-- 等级12 效果怪兽
local s,id=GetID()
function s.initial_effect(c)
	--① 场上有「黑砂爆弹」可直接攻击
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(s.dircon)
	c:RegisterEffect(e1)

	--② 魔·陷·怪兽效果发动时无效破坏 之后自身回手+给对方1500伤害
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12210001,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)

	--③ 自己·对方回合发动：从额外特召「黑砂爆弹」到己方/对方场上
	--冰剑龙同款：发动后下个回合不能使用
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

--① 直接攻击条件
function s.dircon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,12210002)
end

--② 康条件
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end

--② 目标
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	--追加回手、伤害标记
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
end

--② 操作：无效破坏 → 自身回手 → 给予对方1500伤害
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
		--这张卡返回手卡
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			Duel.SendtoHand(c,nil,REASON_EFFECT)
			--给予对方1500伤害
			Duel.Damage(1-tp,1500,REASON_EFFECT)
		end
	end
end

--③ 筛选：黑砂爆弹 12210002
function s.spfilter(c,e,tp)
	return c:IsCode(12210002) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

--③ 冰剑龙同款封锁条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffectLabel(id+100)~=Duel.GetTurnCount()-1
end

--③ 目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

--③ 操作+冰剑龙回合标记
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end

	local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	local p=opt==0 and tp or 1-tp

	if Duel.GetLocationCount(p,LOCATION_MZONE)<=0 then return end

	Duel.SpecialSummon(tc,0,tp,p,false,false,POS_FACEUP)

	--只给③打标记 锁下回合
	if c:IsRelateToEffect(e) then
		c:RegisterFlagEffect(id+100,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2,Duel.GetTurnCount())
	end
end
