-- 绮饿罗・双圣扎拉娜 (ID: 44400029)
local s,id,o=GetID()
function s.initial_effect(c)
	-- 融合召唤手续：「绮饿罗」怪兽＋光・暗属性以外的魔法师族怪兽1只
	c:EnableReviveLimit()
	aux.AddFusionProcMix(c,false,true,s.mfilter1,s.mfilter2)

	-- ①：融合召唤成功的场合或者有怪兽的效果发动的场合才能发动。选卡组1只「绮饿罗」怪兽特殊召唤。这个回合，这张卡以及这个效果特殊召唤的怪兽获得以下效果：
	-- ●自己・对方把卡的效果发动时才能发动。那张卡的原本持有者场上的怪兽的攻击力下降300。
	-- ①-1：融合召唤成功时
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id) -- ①③效果共享 HOPT
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ①-2：有怪兽的效果发动时
	local e1_2=e1:Clone()
	e1_2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1_2:SetCode(EVENT_CHAINING)
	e1_2:SetRange(LOCATION_MZONE)
	e1_2:SetCondition(s.spcon2)
	c:RegisterEffect(e1_2)

	-- ②：自己场上的「绮饿罗」怪兽攻击力上升500，不会成为对方的效果对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)

	-- ③：对方把魔法・陷阱卡发动时才能发动。那个发动无效。那之后，选自己场上1只融合怪兽或者「绮饿罗」怪兽解放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_RELEASE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id) -- ①③效果共享 HOPT
	e4:SetCondition(s.negcon)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end

-- 融合素材过滤
function s.mfilter1(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x444)
end
function s.mfilter2(c,fc,sub,mg,sg)
	return c:IsRace(RACE_SPELLCASTER) and not c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end

-- ①效果 Condition / Target / Operation
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x444) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local sc=g:GetFirst()
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 收集需要赋予效果的目标（自身与特召怪兽）
		local tg=Group.FromCards(sc)
		if c:IsRelateToEffect(e) and c:IsFaceup() then tg:AddCard(c) end
		
		for tc in aux.Next(tg) do
			-- 赋予获得效果：卡的效果发动时，原本持有者场上怪兽攻击力下降300
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetCategory(CATEGORY_ATKCHANGE)
			e1:SetType(EFFECT_TYPE_QUICK_O)
			e1:SetCode(EVENT_CHAINING)
			e1:SetRange(LOCATION_MZONE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCondition(s.atkcon_gained)
			e1:SetTarget(s.atktg_gained)
			e1:SetOperation(s.atkop)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1,true)
		end
	end
end

-- 赋予获得效果的发动条件（同一连锁限 1 次防死循环）
function s.atkcon_gained(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)==0
end

-- 赋予效果的发动检查与操作处理
function s.atkfilter(c,owner)
	return c:IsFaceup() and c:IsControler(owner)
end
function s.atktg_gained(e,tp,eg,ep,ev,re,r,rp,chk)
	local trigger_c=re:GetHandler()
	if chk==0 then return trigger_c and Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,trigger_c:GetOwner()) end
	-- 注册同 1 条连锁限 1 次标记
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,trigger_c:GetOwner())
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,-300)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local trigger_c=re:GetHandler()
	if not trigger_c then return end
	local owner=trigger_c:GetOwner()
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,owner)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end

-- ②效果：加攻与抗性过滤
function s.atktg(e,c)
	return c:IsSetCard(0x444)
end

-- ③效果 Condition / Target / Operation
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and Duel.IsChainNegatable(ev)
end
function s.relfilter(c)
	return (c:IsType(TYPE_FUSION) or c:IsSetCard(0x444)) and c:IsReleasableByEffect()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_MZONE)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		local g=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_MZONE,0,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local sg=g:Select(tp,1,1,nil)
			Duel.Release(sg,REASON_EFFECT)
		end
	end
end