-- 糖果屋的密室 (ID: 20263252)
local s,id,o=GetID()
local CARD_WONDER_CANDY_HOUSE=20263250 -- 「奇妙糖果屋」卡号

function s.initial_effect(c)
	-- 头部必须注册：本卡记述了「奇妙糖果屋」
	aux.AddCodeList(c,CARD_WONDER_CANDY_HOUSE)

	-- 卡片发动（支持发动时直接选用 ① 效果）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e0:SetTarget(s.acttg)
	c:RegisterEffect(e0)

	-- ①：以对方场上1张卡为对象才能发动。那张卡确认，自己把1张卡的种类与那张卡相同的卡从手卡给对方确认...
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id) -- 独立 HOPT ①
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- ②：自己场上有「奇妙糖果屋」存在，对方场上的怪兽把效果发动时可以发动...
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.poscon)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end

-- ==================== 辅助判定函数 ====================
function s.get_card_type(c)
	if c:IsType(TYPE_MONSTER) then return TYPE_MONSTER end
	if c:IsType(TYPE_SPELL) then return TYPE_SPELL end
	if c:IsType(TYPE_TRAP) then return TYPE_TRAP end
	return 0
end

function s.spfilter(c,e,tp)
	-- 严格静态调用 aux.IsCodeListed，检索记述「奇妙糖果屋」的怪兽
	return aux.IsCodeListed(c,CARD_WONDER_CANDY_HOUSE) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_WONDER_CANDY_HOUSE)
end

-- ==================== ① 效果：确认对方场上卡与手卡，特召卡组怪兽 ====================
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
	if chk==0 then return true end
	local b=Duel.GetFlagEffect(tp,id)==0 and s.sptg(e,tp,eg,ep,ev,re,r,rp,0)
	if b and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(s.spop)
		s.sptg(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
			and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end

	-- 那张卡确认
	if tc:IsFacedown() then
		Duel.ConfirmCards(tp,tc)
	end

	local t=s.get_card_type(tc)
	if t==0 then return end

	-- 自己把1张种类相同的卡从手卡给对方确认
	local hg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND,0,nil,t)
	if #hg==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local shg=hg:Select(tp,1,1,nil)
	Duel.ConfirmCards(1-tp,shg)
	Duel.ShuffleHand(tp)

	-- 从卡组把1张记述「奇妙糖果屋」的怪兽特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- ==================== ② 效果：响应怪兽效果、卡组随机比对、变里侧/回手 ====================
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and rp==1-tp and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsLocation(LOCATION_MZONE)
end

function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then
		return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
			and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>0
	end
	Duel.SetTargetCard(rc)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,rc,1,0,0)
end

function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_DECK)
	if #g1==0 or #g2==0 then return end

	-- 从自己·对方卡组各随机选 1 张卡
	local tc1=g1:RandomSelect(tp,1):GetFirst()
	local tc2=g2:RandomSelect(tp,1):GetFirst()
	if not tc1 or not tc2 then return end

	local rg=Group.FromCards(tc1,tc2)
	Duel.ConfirmCards(tp,rg)
	Duel.ConfirmCards(1-tp,rg)

	local t1=s.get_card_type(tc1)
	local t2=s.get_card_type(tc2)
	local is_same=(t1==t2 and t1~=0)

	if is_same then
		-- 种类相同：那只怪兽变为里侧守备表示（严格使用原生 Duel.ChangePosition）
		local rc=re:GetHandler()
		if rc and rc:IsRelateToEffect(re) and rc:IsFaceup() and rc:IsLocation(LOCATION_MZONE) and rc:IsCanTurnSet() then
			Duel.ChangePosition(rc,POS_FACEDOWN_DEFENSE)
		end
	else
		-- 种类不同：场上的这张卡返回手卡
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			Duel.SendtoHand(c,nil,REASON_EFFECT)
		end
	end
end