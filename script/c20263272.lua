-- 王家魔族回音 (ID: 20263272)
local s,id,o=GetID()
function s.initial_effect(c)
	-- ①：丢弃1张手卡才能发动。从卡组把1张「王家魔族」怪兽效果无效特殊召唤。那之后，可以从卡组把1张「王家魔族回音」以外的「王家魔族」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id) -- 效果①独立 HOPT
	e1:SetCost(s.cost1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.activate1)
	c:RegisterEffect(e1)

	-- ②：自己场上有「王家魔族」怪兽上级召唤的场合，把墓地这张卡除外才能发动。从自己墓地把1张「王家魔族」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o*100) -- 效果②独立 HOPT（防撞车规范 id+o*100）
	e2:SetCondition(s.spcon2)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end

-- ==================== 保护机制辅助 ====================
function s.protfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end

function s.efilter(e,ct)
	local p=e:GetHandlerPlayer()
	return ct==Duel.GetCurrentChain()
		and Duel.IsExistingMatchingCard(s.protfilter,p,0,LOCATION_ONFIELD,2,nil)
end

-- ==================== 效果 ① 相关处理 ====================
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 排除自身，防止从手卡发动时将自身作为代价丢弃导致死锁
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,nil,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end

function s.spfilter1(c,e,tp)
	return c:IsSetCard(0x321) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.thfilter1(c)
	return c:IsSetCard(0x321) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 严格使用原生标准的 SetOperationInfo
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)

	-- 只要对方场上有2张以上魔法·陷阱卡存在，这张卡的发动以及那个效果不会被无效化
	if Duel.IsExistingMatchingCard(s.protfilter,tp,0,LOCATION_ONFIELD,2,nil) then
		e:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISEFFECT)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_INACTIVATE)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_DISEFFECT)
		Duel.RegisterEffect(e2,tp)
	else
		e:SetProperty(0)
	end
end

function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end

	-- 从卡组把1张「王家魔族」怪兽效果无效特殊召唤
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
	end

	if Duel.SpecialSummonComplete()>0 then
		-- 那之后，可以从卡组把1张「王家魔族回音」以外的「王家魔族」卡加入手卡
		local sg=Duel.GetMatchingGroup(s.thfilter1,tp,LOCATION_DECK,0,nil)
		if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local hg=sg:Select(tp,1,1,nil)
			Duel.SendtoHand(hg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,hg)
		end
	end
end

-- ==================== 效果 ② 相关处理 ====================
function s.sumfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x321) and c:IsSummonType(SUMMON_TYPE_ADVANCE)
end

function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.sumfilter,1,nil,tp)
end

function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end

function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x321) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end