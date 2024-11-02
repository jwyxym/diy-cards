--幻星集 命运之轮
local m=66660010
local cm=_G["c"..m]
Duel.LoadScript("c666Tarrow.lua")
function cm.initial_effect(c)
	local str="命运之轮开始旋转，世间万事变化无常。\n幻星集的命运之轮啊，请指明前行的方向！"
	XiaoyeServerPublicFunctionLibrary.SummonLines(c,str)
	aux.EnablePendulumAttribute(c)
	xiaoye.PendulumScale(c)
	xiaoye.CannotBeMaterial(c)
	xiaoye.SpecialSummonWithoutPendulum(c)
	xiaoye.PWhenDestory(c)
--roof
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(cm.condition)
	e5:SetTarget(cm.target)
	e5:SetOperation(cm.operation)
	c:RegisterEffect(e5)
--draw
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_DRAW)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_PZONE)
	e6:SetCountLimit(1,m+7)
	e6:SetCost(xiaoye.PendulumEffectCost)
	e6:SetTarget(cm.rooftg)
	e6:SetOperation(cm.roofop)
	c:RegisterEffect(e6)
--set
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1,m+8)
	e7:SetCondition(cm.scon)
	e7:SetTarget(cm.stg)
	e7:SetOperation(cm.sop)
	c:RegisterEffect(e7)
end
function cm.filter(c)
	return c:IsType(TYPE_PENDULUM+TYPE_FIELD+TYPE_SPELL) and c:IsSetCard(0x666) and c:IsAbleToHand()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>5 end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<6 then return end
	local g=Duel.GetDecktopGroup(tp,6)
	Duel.ConfirmCards(tp,g)
	if g:IsExists(cm.filter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:FilterSelect(tp,cm.filter,1,1,nil)
		Duel.DisableShuffleCheck()
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleHand(tp)
		Duel.SortDecktop(tp,tp,5)
	else Duel.SortDecktop(tp,tp,6)
	end
end
function cm.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and re:GetHandler():IsCode(66660030) and not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function cm.scon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and Duel.GetFieldCard(tp,LOCATION_FZONE,0)==nil
end
function cm.stfilter(c,tp)
	return c:IsCode(66660030) and not c:IsForbidden()
end
function cm.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.stfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
end
end
function cm.sop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,cm.stfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		local loc=tc:IsType(TYPE_FIELD) and LOCATION_FZONE or LOCATION_SZONE 
	Duel.MoveToField(tc,tp,tp,loc,POS_FACEUP,true)
	end
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_QUICK_F) and re:GetHandler():IsCode(66660030)
end
function cm.rooffilter(c)
	return c:IsSetCard(0x666) and not c:IsCode(m) and c:IsType(TYPE_PENDULUM)
end
function cm.rooftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.rooffilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function cm.roofop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,cm.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
		if tc then
			Duel.ShuffleDeck(tp)
			Duel.MoveSequence(tc,SEQ_DECKTOP)
			Duel.ConfirmDecktop(tp,1)
		end
	end
end