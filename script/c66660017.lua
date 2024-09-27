--幻星集星星
local m=66660017
local cm=_G["c"..m]
Duel.LoadScript("c666Tarrow.lua")
function cm.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	xiaoye.PendulumScale(c)
	xiaoye.CannotBeMaterial(c)
	xiaoye.CardTargetBeTuner(c)
--
local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCondition(xiaoye.PendulumScaleConditionLeft)
	e3:SetTarget(cm.target1)
	e3:SetOperation(cm.activate1)
	c:RegisterEffect(e3)
--
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1,m+11)
	e4:SetCost(xiaoye.PendulumEffectCost)
	e4:SetCondition(xiaoye.PendulumScaleConditionRight)
	e4:SetTarget(cm.target)
	e4:SetOperation(cm.activate)
	c:RegisterEffect(e4)
--flip
  local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetTarget(cm.target2)
	e5:SetOperation(cm.operation2)
	c:RegisterEffect(e5)
end
function cm.filter2(c,e,tp)
	return c:IsSetCard(0x666) and not c:IsCode(m) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cm.filter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,cm.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP+POS_FACEDOWN_DEFENSE)
			if tc:IsPosition(POS_FACEUP) then
				tc:RegisterFlagEffect(m,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetCountLimit(1)
				e1:SetLabel(fid)
				e1:SetLabelObject(tc)
				e1:SetCondition(cm.dscon)
				e1:SetOperation(cm.dsop)
				e1:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e1,tp)
			else
				Duel.ConfirmCards(1-tp,tc)
			end
		end
	end
end
function cm.dscon(e,tp,eg,ep,ev,re,r,rp)
	local tc1=e:GetLabelObject()
	return tc1:GetFlagEffectLabel(m)==e:GetLabel()
end
function cm.dsop(e,tp,eg,ep,ev,re,r,rp)
	local tc1=e:GetLabelObject()
	Duel.Destroy(tc1,POS_FACEUP,REASON_EFFECT)
end
function cm.filter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(tp)
end
function cm.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(cm.filter,nil,tp)
	Duel.SetTargetCard(g)
	g:AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function cm.filter1(c,e,tp)
	return c:IsSummonPlayer(tp)
		and c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE)
end
function cm.activate1(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(cm.filter1,nil,e,tp)
	local dg=Group.FromCards(e:GetHandler())
	if g then dg:Merge(g) end
	if dg:GetCount()>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
function cm.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SEARCH,nil,1,0,LOCATION_DECK)
end
function cm.filter3(c,e,tp)
	return c:IsSetCard(0x666) and c:IsAbleToHand()
end
function cm.operation2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=2 then return end
	Duel.ConfirmDecktop(tp,3)
	local g=Duel.GetDecktopGroup(tp,3)
	local ct=g:GetCount()
	if ct>0 and g:FilterCount(cm.filter3,nil,e,tp)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:FilterSelect(tp,cm.filter3,1,1,nil,e,tp)
		local tc=sg:GetFirst()
		if tc then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleHand(tp)
			g:Sub(sg)
		end
	end
	Duel.ShuffleDeck(tp)
end