--幻星集月亮
local m=66660018
local cm=_G["c"..m]
Duel.LoadScript("c666Tarrow.lua")
function cm.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	xiaoye.PendulumScale(c)
	xiaoye.CannotBeMaterial(c)
--p
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,m+11)
	e3:SetCondition(xiaoye.PendulumScaleConditionLeft)
	e3:SetCost(xiaoye.PendulumEffectCost)
	e3:SetTarget(cm.postg)
	e3:SetOperation(cm.posop)
	c:RegisterEffect(e3)
--facedown
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_PZONE)
	e4:SetTargetRange(1,0)
	e4:SetCountLimit(1,66660046)
	e4:SetCost(xiaoye.PendulumEffectCost)
	e4:SetCondition(xiaoye.PendulumScaleConditionRight)
	e4:SetTarget(cm.target1)
	e4:SetOperation(cm.activate1)
	c:RegisterEffect(e4)
--summon
local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_POSITION)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetTarget(cm.target)
	e5:SetOperation(cm.activate)
	c:RegisterEffect(e5)
local e6=e5:Clone()
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_DECKDES)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetTarget(cm.grave)
	e7:SetOperation(cm.tograve)
	c:RegisterEffect(e7)
end
function cm.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and cm.filter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,cm.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFirstTarget()
	if g then
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
function cm.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetFieldCard(e:GetHandlerPlayer(),LOCATION_PZONE,1)
	if not a or not a:IsType(TYPE_PENDULUM) then return end
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function cm.posop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetFieldCard(e:GetHandlerPlayer(),LOCATION_PZONE,1)
	if not a then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Destroy(a,REASON_EFFECT)~=0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
	end
end
function cm.grave(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_DECK)
end
function cm.gravefilter(c,e,tp)
		return c:IsSetCard(0x666) and c:IsType(TYPE_PENDULUM)  and not c:IsType(TYPE_RITUAL) and c:IsAbleToGrave()
end
function cm.tograve(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=2 then return end
	Duel.ConfirmDecktop(tp,3)
	local g=Duel.GetDecktopGroup(tp,3)
	local ct=g:GetCount()
	if ct>0 and g:FilterCount(cm.gravefilter,nil,e,tp)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:FilterSelect(tp,cm.gravefilter,1,1,nil,e,tp)
	local tc2=sg:GetFirst()
	if tc2 then
		Duel.SendtoGrave(tc2,REASON_EFFECT)
	end
	end
Duel.ShuffleDeck(tp)
end
function cm.filter1(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsCanTurnSet()
end
function cm.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(cm.filter1,nil,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function cm.activate1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
	Duel.BreakEffect()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)~=0 then
		local og=Duel.GetOperatedGroup()
		local tc=og:GetFirst()
		while tc do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc=og:GetNext()
		end
	end
	end
end