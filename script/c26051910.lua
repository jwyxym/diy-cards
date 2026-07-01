-- 新星同盟 修整时间
-- ID: 26051910
-- 字段: 新星同盟 (0x902)
local s,id=GetID()
function s.initial_effect(c)
	-- ② 卡的发动效果处理：检索1张「新星同盟」卡，然后丢弃1张手卡
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id)                                       -- 一回合一次
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_HANDES)
	e0:SetTarget(s.acttg)
	e0:SetOperation(s.actop)
	c:RegisterEffect(e0)

	-- ① 自己场上的「新星同盟」怪兽不会被战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x902))
	e1:SetValue(1)
	c:RegisterEffect(e1)

	-- ③ 自己·对方的准备阶段，墓地·除外3张「新星同盟」卡回卡组，然后抽1张
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+1)                                     -- 一回合一次（与②独立）
	e3:SetTarget(s.rectg)
	e3:SetOperation(s.recop)
	c:RegisterEffect(e3)
end

-- ② 发动目标：卡组有可检索的「新星同盟」卡
function s.thfilter(c)
	return c:IsSetCard(0x902) and c:IsAbleToHand()
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ② 处理：检索1张，然后丢弃1张手卡
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.BreakEffect()
		-- 丢弃1张手卡（若无手卡则不丢弃）
		if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then
			Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
		end
	end
end

-- ③ 回收过滤：墓地·除外可回卡组的「新星同盟」卡
function s.recfilter(c)
	return c:IsSetCard(0x902) and c:IsAbleToDeck()
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.recfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.recfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if g:GetCount()<3 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:Select(tp,3,3,nil)
	if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end