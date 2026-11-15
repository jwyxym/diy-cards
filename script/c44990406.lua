--探险者之力-正义感召
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

	-- ② 对方怪兽效果处理时，送墓自己场上1只「探险者」怪兽来无效
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.discon)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)

	-- ③ 墓地效果：这张卡和1张「探险者」卡回到手卡
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+1)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
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

-- ② 可送墓的「探险者」怪兽
function s.costfilter(c)
	return c:IsSetCard(0x0cf3) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end

-- ② 条件：对方发动怪兽效果、效果可无效、自己场上有「探险者」怪兽、本回合未使用
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
		and Duel.GetFlagEffect(tp,id)==0
		and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- ② 操作：询问是否发动，送墓「探险者」怪兽并无效效果
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,2)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g==0 then return end
	Duel.SendtoGrave(g,REASON_EFFECT)
	Duel.Hint(HINT_CARD,0,id)
	Duel.NegateEffect(ev)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

-- ③ 「探险者」卡（排除自身）
function s.thfilter(c,e)
	return c:IsSetCard(0x0cf3) and c:IsAbleToHand() and c~=e:GetHandler()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc,e) end
	if chk==0 then
		return c:IsAbleToHand()
			and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,e)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end

-- ③ 操作：把这张卡和对象卡一起回到手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=Group.CreateGroup()
	if c:IsRelateToEffect(e) then tg:AddCard(c) end
	if g then
		tg:Merge(g:Filter(Card.IsRelateToEffect,nil,e))
	end
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end