--幻星集 世界
local m=66660021
local cm=_G["c"..m]
Duel.LoadScript("c666Tarrow.lua")
function cm.initial_effect(c)
	local str="胜利之门已然出现，努力终将有所回报。\n幻星集的世界降临于此，引领我完成最后的步骤！"
	XiaoyeServerPublicFunctionLibrary.SummonLines(c,str)
	aux.EnablePendulumAttribute(c)
	xiaoye.PendulumScale(c)
	xiaoye.CannotBeMaterial(c)
	xiaoye.CardTargetBeTuner(c)
	xiaoye.SpecialSummonWithoutPendulum(c)
	xiaoye.PWhenDestory(c)
--material
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(m,0))
	e5:SetCountLimit(1)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(cm.oltg)
	e5:SetOperation(cm.olop)
	c:RegisterEffect(e5)
--negate
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(m,1))
	e6:SetCategory(CATEGORY_DISABLE)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCost(cm.cost)
	e6:SetTarget(cm.target)
	e6:SetOperation(cm.operation)
	c:RegisterEffect(e6)
--set
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_PZONE)
	e7:SetCountLimit(1,m+11)
	e7:SetCost(xiaoye.PendulumEffectCost)
	e7:SetTarget(cm.stg)
	e7:SetOperation(cm.sop)
	c:RegisterEffect(e7)
end
function cm.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function cm.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function cm.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function cm.matfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x666) and c:IsCanOverlay() and c:IsFaceup()
end
function cm.oltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.matfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
function cm.olop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,cm.matfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		if g then
			Duel.Overlay(e:GetHandler(),g)
		end
	end
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE+LOCATION_FZONE) and aux.NegateAnyFilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_SZONE+LOCATION_FZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_SZONE+LOCATION_FZONE,1,1,nil)
	Duel.SetOperationInfo(0,LOCATION_SZONE+LOCATION_FZONE,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if ((tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) and tc:IsRelateToEffect(e) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function cm.stfilter(c,tp)
	return c:IsSetCard(0x666) and c:IsType(TYPE_FIELD+TYPE_CONTINUOUS) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function cm.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.stfilter,tp,LOCATION_DECK,0,1,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function cm.sop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,cm.stfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		local loc=tc:IsType(TYPE_FIELD) and LOCATION_FZONE or LOCATION_SZONE 
	Duel.MoveToField(tc,tp,tp,loc,POS_FACEUP,true)
	end end
end
