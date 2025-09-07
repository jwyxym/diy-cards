--蔑视之龙 闭界之霾
local s,id,o=GetID()
function s.initial_effect(c)
	--search
	 local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--send to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.cost1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.showfilter(c)
	return ((c:IsLevelAbove(10) and c:IsRace(RACE_DRAGON+RACE_WYRM)) or (c:IsType(TYPE_SPELL) and c:IsType(TYPE_RITUAL))) and not c:IsPublic()
end
function s.mgfilter(c)
	return c:IsLevelAbove(10) and c:IsRace(RACE_WYRM) and c:IsType(TYPE_RITUAL) and c:IsAbleToGraveAsCost()
end
-- 检索的卡条件
function s.thfilter(c)
	return (c:IsSetCard(0x681) or (c:IsType(TYPE_SPELL) and c:IsType(TYPE_RITUAL))) and c:IsAbleToHand()
end
-- 代价处理：展示手卡
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 检查是否有符合条件的其他手卡
		return Duel.IsExistingMatchingCard(s.showfilter,tp,LOCATION_HAND,0,1,c)
			and Duel.IsExistingMatchingCard(s.mgfilter,tp,LOCATION_DECK,0,1,nil)
	end
	-- 选择并展示手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.showfilter,tp,LOCATION_HAND,0,1,1,c)
	if #g>0 then
		local showg=Group.FromCards(c,g:GetFirst())
		Duel.ConfirmCards(1-tp,showg)
		Duel.ShuffleHand(tp)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLevelBelow(9)
end
-- 目标设置
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.mgfilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组选择怪兽送去墓地
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local mg=Duel.SelectMatchingCard(tp,s.mgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #mg==0 then return end
	
	if Duel.SendtoGrave(mg,REASON_EFFECT)~=0 then
		-- 从卡组检索卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local thg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #thg>0 then
			Duel.SendtoHand(thg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,thg)
		end
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local tc=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
		if tc then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end
function s.thfilter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x681) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter1(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter1,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1=Duel.SelectTarget(tp,s.thfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,nil)
	if #g==0 then return end
	Duel.HintSelection(g)
	if Duel.Destroy(g,REASON_EFFECT)~=0 and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
