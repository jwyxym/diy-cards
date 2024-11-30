--百鬼夜行 滑头鬼
local cm,m,o=GetID()
Duel.LoadScript("c666Hyakkiyakou.lua")
function cm.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--spsummon rule
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,m+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(cm.sprcon)
	e1:SetOperation(cm.sprop)
	c:RegisterEffect(e1)
	xiaoye.MonsterEffectAndGrant(c,m,CATEGORY_TOHAND+CATEGORY_SEARCH,EFFECT_TYPE_IGNITION,0,0,1,0,cm.thtg,cm.thop,0)
end
function cm.cfilter(c,tp)
	return c:IsSetCard(0x5660) and c:IsType(TYPE_PENDULUM)
end
function cm.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(cm.cfilter,tp,LOCATION_HAND,0,1,c,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function cm.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(26237713,0))
	local g=Duel.SelectMatchingCard(tp,cm.cfilter,tp,LOCATION_HAND,0,1,1,c,tp)
	Duel.SendtoExtraP(g,nil,REASON_COST)
end
function cm.thfilter(c)
	return c:IsSetCard(0x5660) and c:IsAbleToHand()
end
function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cm.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end