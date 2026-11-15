--篡夺的据点
local s,id,o=GetID()
function s.initial_effect(c)
	--发动这张卡
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--①：自己主要阶段，从卡组把「黄金」·「篡夺」卡合计最多2张加入手卡，2张的场合再丢弃1张手卡，这张卡送去墓地
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--②：自己场上没有「篡夺」怪兽以外的怪兽的场合，自己的「篡夺」怪兽不会成为对手效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(s.monfilter))
	e2:SetValue(aux.tgoval)
	e2:SetCondition(s.con2)
	c:RegisterEffect(e2)
end
--①：可检索的「黄金」·「篡夺」卡
function s.thfilter(c)
	return (c:IsSetCard(0x570) or c:IsSetCard(0x571)) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,2,nil)
	if g:GetCount()==0 then return end
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
	if g:GetCount()<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
	if dg:GetCount()>0 then Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD) end
	if c:IsRelateToEffect(e) then Duel.SendtoGrave(c,REASON_EFFECT) end
end
--②：「篡夺」怪兽
function s.monfilter(c)
	return c:IsSetCard(0x570) and c:IsType(TYPE_MONSTER)
end
--②：自己场上怪兽数与「篡夺」怪兽数相同（即没有「篡夺」以外的怪兽）
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(nil,tp,LOCATION_MZONE,0,nil)
	return ct==Duel.GetMatchingGroupCount(s.monfilter,tp,LOCATION_MZONE,0,nil)
end
