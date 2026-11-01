--山水-云雾
local s,id,o=GetID()
function c12260009.initial_effect(c)
	--①
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12260009,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,12260009)
	e1:SetCost(c12260009.flipcost)
	e1:SetTarget(c12260009.thtg)
	e1:SetOperation(c12260009.thop)
	c:RegisterEffect(e1)
	--②
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12260009,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,89631152)
	e2:SetCondition(c12260009.thcon)
	e2:SetTarget(c12260009.thtg2)
	e2:SetOperation(c12260009.thop2)
	c:RegisterEffect(e2)
end

--①cost筛选：场上任意可以变更表示形式的怪兽
function c12260009.cfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsCanChangePosition()
end
function c12260009.flipcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c12260009.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,c12260009.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc:IsFacedown() then
		--里侧怪兽 → 翻表，选择攻击/守备
		Duel.ConfirmCards(1-tp,g)
		local sel=Duel.SelectOption(tp,aux.Stringid(12260009,2),aux.Stringid(12260009,3))
		if sel==0 then
			Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
		else
			Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		end
	else
		--表侧怪兽（表攻/表守）→ 变为里侧守备
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end

function c12260009.thfilter(c)
	return c:IsSetCard(0x63a0) and not c:IsCode(12260009) and c:IsAbleToHand()
end
function c12260009.spfilter(c,e,tp)
	return c:IsSetCard(0x63a0) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function c12260009.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(c12260009.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c12260009.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c12260009.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()==0 then return end
	if Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c12260009.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(12260009,4)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=sg:Select(tp,1,1,nil):GetFirst()
			if sc then
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
			end
		end
	end
end

--②条件不变：里侧的这张从场上送墓
function c12260009.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEDOWN) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function c12260009.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,LOCATION_MZONE)
end
--②效果后选择分支：
--分支A：里侧守备怪兽 → 翻成表攻/表守
--分支B：表侧怪兽 → 盖成里侧守备
function c12260009.posfilter2(c)
	return c:IsCanChangePosition() and c:IsLocation(LOCATION_MZONE)
end
function c12260009.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_HAND)) then return end
	local g=Duel.GetMatchingGroup(c12260009.posfilter2,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(12260009,5)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if not tc then return end
		if tc:IsFacedown() then
			--里侧守备：翻表，选攻击/守备
			Duel.ConfirmCards(1-tp,tc)
			local sel=Duel.SelectOption(tp,aux.Stringid(12260009,2),aux.Stringid(12260009,3))
			if sel==0 then
				Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
			else
				Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
			end
		else
			--表侧任意 → 盖成里侧守备
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	end
end
