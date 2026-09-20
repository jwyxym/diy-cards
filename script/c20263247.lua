-- 糖果屋的访客-格莱特 (ID: 20263247)
local s,id,o=GetID()
local CARD_WONDER_CANDY_HOUSE=20263250 -- 「奇妙糖果屋」卡号

function s.initial_effect(c)
	-- 头部必须注册：本卡记述了「奇妙糖果屋」
	aux.AddCodeList(c,CARD_WONDER_CANDY_HOUSE)

	-- ①：这个回合，已是有卡加入对方手卡的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id) -- 独立 HOPT ①
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己·对方卡组各随机选1张卡给双方确认...
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o*100) -- 独立 HOPT ② (防撞限制码)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e2_2=e2:Clone()
	e2_2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2_2)

	-- 全局监听：记录本回合有卡加入手卡的玩家
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_HAND)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		local p=tc:GetControler()
		Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1)
	end
end

-- ==================== ① 效果：对方本回合有卡加手时特召 ====================
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(1-tp,id)>0
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

-- ==================== ② 效果：随机翻卡比对与追加检索魔陷 ====================
function s.get_card_type(c)
	if c:IsType(TYPE_MONSTER) then return TYPE_MONSTER end
	if c:IsType(TYPE_SPELL) then return TYPE_SPELL end
	if c:IsType(TYPE_TRAP) then return TYPE_TRAP end
	return 0
end

function s.thfilter(c)
	-- 严格静态调用 aux.IsCodeListed，检索记述「奇妙糖果屋」的魔法·陷阱卡
	return aux.IsCodeListed(c,CARD_WONDER_CANDY_HOUSE) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
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

	-- 这个效果把魔法卡加入自己·对方手卡的场合，可以从卡组把1张有「奇妙糖果屋」的卡名记述的魔法·陷阱卡加入手卡
	if added_card and added_card:IsLocation(LOCATION_HAND) and added_card:IsType(TYPE_SPELL)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local hg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #hg>0 then
			Duel.SendtoHand(hg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,hg)
		end
	end
end