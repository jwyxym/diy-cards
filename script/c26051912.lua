-- 新星同盟 寻找伙伴
-- ID: 26051912
-- 字段：新星同盟 (0x902)
local s,id=GetID()
function s.initial_effect(c)
	-- 卡的发动：检索1只怪兽，视情况可特招手牌怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end

-- 过滤函数：星之卡比
function s.kirbyfilter(c)
	return c:IsSetCard(0x902) and c:IsCode(26051902) and c:IsFaceup()
end

-- 检索目标
function s.thfilter(c)
	return c:IsSetCard(0x902) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索1张新星同盟怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		Duel.ConfirmCards(1-tp,g)
		-- 如果自己场上有「新星同盟 星之卡比」，可特招手牌1只新星同盟怪兽
		if Duel.IsExistingMatchingCard(s.kirbyfilter,tp,LOCATION_MZONE,0,1,nil) then
			local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
			if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local spg=sg:Select(tp,1,1,nil)
				Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x902) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end