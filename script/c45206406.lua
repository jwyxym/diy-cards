--缚魂灵-范无咎
local s,id=GetID()
function s.initial_effect(c)
	-- ① 展示手卡的这张卡才能发动。从手卡把1只「缚魂灵」怪兽召唤（1回合1次）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- ② 召唤成功时，拿1张本家魔陷或对方卡（无次数限制）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	-- 无次数限制
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)

	-- ③ 被解放的场合，各解放1张本家和对方卡，视作融合特召8星以下本家融合（1回合1次）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+200)
	e3:SetCost(s.fuscost) -- ★ 将解放作为 COST 支付
	e3:SetTarget(s.fustg)
	e3:SetOperation(s.fusop)
	c:RegisterEffect(e3)
end

-- ================= ① 效果 =================

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.ConfirmCards(1-tp, e:GetHandler())
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

function s.thfilter(c,tp)
	-- 本家魔陷（可以从卡组/墓地拿）
	if c:IsSetCard(0x1fa3) and c:IsType(TYPE_SPELL+TYPE_TRAP) then return true end
	-- 原本持有者是对方的卡（只能从卡组拿，但为了统一判定，用位置过滤）
	if c:GetOwner()==1-tp then return true end
	return false
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,tp)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		if sg:GetCount()>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleDeck(tp)
		end
	end
end

-- ================= ③ 效果 =================

-- 融合素材过滤（用于后续判定）
function s.fusfilter(c,tp)
	return (c:IsSetCard(0x1fa3) and c:IsType(TYPE_MONSTER)) or c:GetOwner()==1-tp
end

-- ★ 核心修复：分别选1张本家，和1张对方卡作为 Cost
function s.fuscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		-- 必须同时满足：有1张本家，有1张对方卡
		return Duel.IsExistingMatchingCard(s.matfilter1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(s.matfilter2,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,1,nil,tp)
	end
	
	-- 1. 选1张本家解放
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g1=Duel.SelectMatchingCard(tp,s.matfilter1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,1,1,nil)
	Duel.Release(g1,REASON_COST)
	
	-- 2. 选1张对方卡解放
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g2=Duel.SelectMatchingCard(tp,s.matfilter2,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,1,1,nil,tp)
	Duel.Release(g2,REASON_COST)
end

function s.matfilter1(c)
	return c:IsSetCard(0x1fa3) and c:IsType(TYPE_MONSTER) and c:IsReleasable()
end

function s.matfilter2(c,tp)
	return c:GetOwner()==1-tp and c:IsReleasable()
end

-- 过滤：8星以下的本家融合怪
function s.fusfilter_extra(c,e,tp)
	return c:IsSetCard(0x1fa3) and c:IsType(TYPE_FUSION) 
		and c:IsLevelBelow(8) 
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end

function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.GetLocationCountFromEx(tp,tp,nil,nil)>0
			and Duel.IsExistingMatchingCard(s.fusfilter_extra,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCountFromEx(tp,tp,nil,nil)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.fusfilter_extra,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc = g:GetFirst()
		-- 视作正规融合召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	end
end

return s