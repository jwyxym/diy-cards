--缚魂灵域-酆都城
local s,id=GetID()
function s.initial_effect(c)
	-- ① 作为这张卡的发动时的效果处理：可选从卡组·墓地拿卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- ② 展示手卡1只本家怪兽，从卡组解放1只本家怪兽（1回合1次）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(s.rlcost)
	e2:SetTarget(s.rltg)
	e2:SetOperation(s.rlop)
	c:RegisterEffect(e2)

	-- ③ 场上有怪兽特召的场合，从手卡把1只本家怪兽召唤（无次数限制）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	-- ★ 只加了这一行：修复时点，变成“场合”效果
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(s.sumtg)
	e3:SetOperation(s.sumop)
	c:RegisterEffect(e3)
end

-- ================= ① 效果 =================

function s.thfilter(c,tp)
	if c:IsSetCard(0x1fa3) then return true end
	if c:GetOwner()==1-tp then return true end
	return false
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,tp)
	if g:GetCount()==0 then return end
	
	if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		if sg:GetCount()>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleDeck(tp)
		end
	end
end

-- ================= ② 效果 =================

function s.rlfilter(c)
	return c:IsSetCard(0x1fa3) and c:IsType(TYPE_MONSTER)
end

-- ★ 核心修复：选 1 张展示，只看一眼，不加任何 Buff
function s.rlcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rlfilter,tp,LOCATION_HAND,0,1,nil) end
	
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
	local sg = Duel.SelectMatchingCard(tp, s.rlfilter, tp, LOCATION_HAND, 0, 1, 1, nil)
	if sg:GetCount()>0 then
		-- 只展示这 1 张
		Duel.ConfirmCards(1-tp, sg)
		-- 不加任何 EFFECT_PUBLIC，对方看一眼后就恢复隐藏
	end
end

function s.relfilter(c)
	return c:IsSetCard(0x1fa3) and c:IsType(TYPE_MONSTER) and c:IsReleasable()
end

function s.rltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_DECK,0,1,nil) end
end

function s.rlop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local sg=g:Select(tp,1,1,nil)
		if sg:GetCount()>0 then
			Duel.Release(sg,REASON_EFFECT)
		end
	end
end

-- ================= ③ 效果 =================

function s.sumfilter(c)
	return c:IsSetCard(0x1fa3) and c:IsType(TYPE_MONSTER) and c:IsSummonable(true,nil)
end

function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Summon(tp, g:GetFirst(), true, nil)
	end
end

return s