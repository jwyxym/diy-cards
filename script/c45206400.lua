--缚魂灵-罗刹
local s,id=GetID()
function s.initial_effect(c)
	-- ① 召唤时展示对方卡组顶5张，选2张加入自己卡组并洗切，附带额外特召自诉（无次数限制）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	-- ★ 删除了 e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg1)
	e1:SetOperation(s.tgop1)
	c:RegisterEffect(e1)

	-- ② 被解放的场合，拿1本家+1对方卡，并获得追加统招（1回合1次）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.rltg2)
	e2:SetOperation(s.rlop2)
	c:RegisterEffect(e2)
end

-- ================= ① 效果 =================
function s.tgtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=1 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,0)
end

function s.tgop1(e,tp,eg,ep,ev,re,r,rp)
	-- 注册自诉
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	local g=Duel.GetDecktopGroup(1-tp,5)
	if g:GetCount()==0 then return end
	Duel.ConfirmDecktop(1-tp,5)
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:Select(tp,2,2,nil)
	if sg:GetCount()>0 then
		Duel.SendtoDeck(sg,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.ShuffleDeck(tp)
	end
end

-- ★ 官方同款自诉判定
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) 
		and not c:IsSetCard(0x1fa3) 
		and c:GetOwner() ~= 1 - e:GetHandlerPlayer()
end

-- ================= ② 效果 =================
function s.rlfilter1(c,tp)
	return c:IsSetCard(0x1fa3) and c:IsAbleToHand()
end

function s.rlfilter2(c,tp)
	return c:GetOwner()==1-tp and c:IsAbleToHand()
end

function s.rltg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.rlfilter1,tp,LOCATION_DECK,0,1,nil,tp)
			and Duel.IsExistingMatchingCard(s.rlfilter2,tp,LOCATION_DECK,0,1,nil,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end

function s.rlop2(e,tp,eg,ep,ev,re,r,rp)
	-- 1. 拿本家
	local g1=Duel.GetMatchingGroup(s.rlfilter1,tp,LOCATION_DECK,0,nil,tp)
	if g1:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg1=g1:Select(tp,1,1,nil)
		if sg1:GetCount()>0 then
			Duel.SendtoHand(sg1,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg1)
		end
	end

	-- 2. 拿对方卡
	local g2=Duel.GetMatchingGroup(s.rlfilter2,tp,LOCATION_DECK,0,nil,tp)
	if g2:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg2=g2:Select(tp,1,1,nil)
		if sg2:GetCount()>0 then
			Duel.SendtoHand(sg2,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg2)
		end
	end
	Duel.ShuffleDeck(tp)

	-- 3. 追加通常召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

return s