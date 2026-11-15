--缚魂灵-阿防
local s,id=GetID()
function s.initial_effect(c)
	-- ① 只能从手卡发动：除外卡，通常召唤本家（1回合1次）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SUMMON) 
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- ② 召唤成功时，解放1只本家，选对方场上/墓地/除外的1张卡加入自己卡组（无次数限制）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCost(s.rlcost)
	e2:SetTarget(s.rltg)
	e2:SetOperation(s.rlop)
	c:RegisterEffect(e2)

	-- ③ 被解放的场合，从卡组拿/特召（1回合1次）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+200)
	e3:SetTarget(s.rltg3)
	e3:SetOperation(s.rlop3)
	c:RegisterEffect(e3)
end

-- ================= ① 效果 =================

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		-- 修复核心：分别检测 手卡/额外（公开区域）和 卡组（非公开区域）
		return Duel.IsExistingMatchingCard(s.confilter_hand_extra,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,tp)
			or Duel.IsExistingMatchingCard(s.confilter_deck,tp,LOCATION_DECK,0,1,nil,tp)
	end
	-- 玩家选择剔除哪里的卡
	local g=Duel.GetMatchingGroup(s.confilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,nil,tp)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=g:Select(tp,1,1,nil)
		Duel.Remove(sg,POS_FACEUP,REASON_COST)
	end
end

-- 手卡和额外卡组的判定（可以明牌看）
function s.confilter_hand_extra(c,tp)
	return c:GetOwner()==1-tp and c:IsAbleToRemoveAsCost()
end

-- 卡组的判定（不能看，但探测底层是否存在属于对方的卡，且能作为代价除外）
function s.confilter_deck(c,tp)
	return c:GetOwner()==1-tp and c:IsAbleToRemoveAsCost()
end

function s.confilter(c,tp)
	return c:GetOwner()==1-tp and c:IsAbleToRemoveAsCost()
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1fa3) and c:IsType(TYPE_MONSTER) and c:IsSummonable(true,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.Summon(tp, g:GetFirst(), true, nil)
	end
end

-- ================= ② 效果 =================

function s.rlcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.CheckReleaseGroup(tp,s.rlfiltercost,1,nil) 
			or Duel.IsExistingMatchingCard(s.rlfiltercost,tp,LOCATION_DECK,0,1,nil)
	end
	
	local g=Duel.GetMatchingGroup(s.rlfiltercost,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_DECK,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local sg=g:Select(tp,1,1,nil)
		Duel.Release(sg,REASON_COST)
	end
end

function s.rlfiltercost(c)
	return c:IsSetCard(0x1fa3) and c:IsType(TYPE_MONSTER) and c:IsReleasable()
end

function s.rlfilter2(c,tp)
	if c:IsLocation(LOCATION_ONFIELD) then
		return c:IsFaceup()
	elseif c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED) then
		return true
	end
	return false
end

function s.rltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rlfilter2,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.rlop(e,tp,eg,ep,ev,re,r,rp)
	-- 誓约限制
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	-- 把对方卡加入自己卡组
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.rlfilter2,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,1,1,nil,tp)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.SendtoDeck(tc,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end

	-- 追加通常召唤
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end

function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) 
		and not c:IsSetCard(0x1fa3) 
		and c:GetOwner() ~= 1 - e:GetHandlerPlayer()
end

-- ================= ③ 效果 =================

function s.thfilter3(c,tp)
	return (c:GetOwner()==1-tp or c:IsSetCard(0x1fa3)) 
		and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end

function s.rltg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.thfilter3,tp,LOCATION_DECK,0,1,nil,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.rlop3(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter3,tp,LOCATION_DECK,0,nil,tp)
	if g:GetCount()==0 then return end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:Select(tp,1,1,nil)
	if sg:GetCount()==0 then return end
	local tc=sg:GetFirst()
	
	local b1=tc:IsAbleToHand()
	local b2=tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	
	if b1 and b2 then
		if Duel.SelectOption(tp,1190,1152)==0 then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
			Duel.ShuffleDeck(tp)
		else
			Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		end
	elseif b1 then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
		Duel.ShuffleDeck(tp)
	elseif b2 then
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
	end
end

return s