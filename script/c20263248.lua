-- 糖果屋的主人 (ID: 20263248)
local s,id,o=GetID()
local CARD_WONDER_CANDY_HOUSE=20263250 -- 「奇妙糖果屋」卡号

function s.initial_effect(c)
	-- 头部必须注册：本卡记述了「奇妙糖果屋」
	aux.AddCodeList(c,CARD_WONDER_CANDY_HOUSE)

	-- ①：自己·对方回合，把自己手卡·场上1张原本持有者是对方的卡给对方确认才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id) -- 独立 HOPT ①
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- ②：自己·对方主要阶段才能发动。从自己·对方卡组各随机选1张卡给双方确认...
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id+o*100) -- 独立 HOPT ② (防撞限制码)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

-- ==================== ① 效果：展示原本属于对方的卡特召 ====================
function s.costfilter(c,tp)
	-- 修正：使用原生 GetOwner() 代替不存在的 IsOwner 方法
	return c:GetOwner()==1-tp and (c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_ONFIELD))
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- ==================== ② 效果：主要阶段随机翻卡比对、追加炸卡与抽卡 ====================
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

function s.get_card_type(c)
	if c:IsType(TYPE_MONSTER) then return TYPE_MONSTER end
	if c:IsType(TYPE_SPELL) then return TYPE_SPELL end
	if c:IsType(TYPE_TRAP) then return TYPE_TRAP end
	return 0
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_WONDER_CANDY_HOUSE)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
			and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_ALL,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
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

	local added_card=nil

	if is_same then
		-- 相同：自己可以从中选1张加入手卡
		if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=rg:FilterSelect(tp,Card.IsAbleToHand,1,1,nil,tp)
			if #sg>0 then
				Duel.SendtoHand(sg,tp,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
				added_card=sg:GetFirst()
			end
		end
	else
		-- 不相同：对方可以从中选1张加入其自身手卡
		if Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
			local sg=rg:FilterSelect(1-tp,Card.IsAbleToHand,1,1,nil,1-tp)
			if #sg>0 then
				Duel.SendtoHand(sg,1-tp,REASON_EFFECT)
				Duel.ConfirmCards(tp,sg)
				added_card=sg:GetFirst()
			end
		end
	end

	-- 这个效果把陷阱卡加入自己·对方手卡的场合，可以再把对方场上1张卡破坏
	if added_card and added_card:IsLocation(LOCATION_HAND) and added_card:IsType(TYPE_TRAP)
		and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #dg>0 then
			Duel.HintSelection(dg)
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end

	-- 自己场上有「奇妙糖果屋」存在的场合，可以再从卡组抽1张卡
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsPlayerCanDraw(tp,1)
		and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end