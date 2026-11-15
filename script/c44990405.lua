--探险者之力-这是什么?
local s,id=GetID()
function s.initial_effect(c)
	-- 同名卡在自己场上只能有1张表侧表示存在
	c:SetUniqueOnField(1,0,id)

	-- 装备魔法的激活效果
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_EQUIP)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e0:SetTarget(s.eqtg)
	e0:SetOperation(s.eqop)
	c:RegisterEffect(e0)

	-- 装备限制：只能装备给「探险者」怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(s.eqlimit)
	c:RegisterEffect(e1)

	-- ② 以场上1只表侧怪兽为对象，从卡组把1张其可装备的装备魔法给它装备
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.quiptg)
	e2:SetOperation(s.quipop)
	c:RegisterEffect(e2)

	-- ③ 这张卡从场上送去墓地的场合：检索「探险者」怪兽，之后可以召唤1只「探险者」怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+2)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

-- 装备限制：只能装备给「探险者」怪兽（字段 0x0cf3）
function s.eqlimit(e,c)
	return c:IsSetCard(0x0cf3) and c:IsType(TYPE_MONSTER)
end

-- 可装备对象
function s.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x0cf3) and c:IsType(TYPE_MONSTER)
end

-- 激活目标
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.eqfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

-- 激活操作
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup()
		and c:CheckUniqueOnField(tp) then
		Duel.Equip(tp,c,tc)
	end
end

-- ② 目标：场上表侧怪兽，且卡组存在可装备给它的装备魔法
function s.quipfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
function s.quiptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.quipfilter(chkc) end
	if chk==0 then
		if not Duel.IsExistingTarget(s.quipfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then return false end
		local g=Duel.GetMatchingGroup(s.quipfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		local has=false
		for tc in aux.Next(g) do
			if Duel.IsExistingMatchingCard(s.deckequipfilter,tp,LOCATION_DECK,0,1,nil,tc) then
				has=true
				break
			end
		end
		return has
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local sg=Duel.SelectTarget(tp,s.quipfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end

-- 卡组中可装备给指定怪兽的装备魔法
function s.deckequipfilter(c,tc)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(tc)
end

-- ② 操作：从卡组选择1张可装备的装备魔法并装备
function s.quipop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.deckequipfilter,tp,LOCATION_DECK,0,1,1,nil,tc)
	if #g>0 then
		Duel.Equip(tp,g:GetFirst(),tc)
	end
end

-- ③ 条件：从场上送去墓地
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end

-- ③ 检索「探险者」怪兽
function s.thfilter(c)
	return c:IsSetCard(0x0cf3) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,0,0,0)
end

-- ③ 可召唤的「探险者」怪兽
function s.sumfilter(c)
	return c:IsSetCard(0x0cf3) and c:IsType(TYPE_MONSTER) and c:IsSummonable(true,nil)
end

-- ③ 操作：检索，之后可选通常召唤1只「探险者」怪兽
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 then return end
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)

	local sg=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND,0,nil)
	if #sg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local sc=sg:Select(tp,1,1,nil):GetFirst()
		if sc then
			-- 通常召唤，消耗通常召唤次数
			Duel.Summon(tp,sc,false,nil)
		end
	end
end