--幻星集 正义
local m=66660011
local cm=_G["c"..m]
Duel.LoadScript("c666Tarrow.lua")
function cm.initial_effect(c)
	xiaoye.CannotBeMaterial(c)
	--Synchro summon
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
--add
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,m+8)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
--set
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,m+9)
	e2:SetTarget(cm.settg)
	e2:SetOperation(cm.setop)
	c:RegisterEffect(e2)
--level
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_LEVEL)
	e3:SetValue(-4)
	c:RegisterEffect(e3)
end
function cm.setfilter(c,tp)
	return c:IsSetCard(0x666) and c:IsType(TYPE_CONTINUOUS) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function cm.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cm.setfilter(chkc,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(cm.setfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	local ct=math.min((Duel.GetLocationCount(tp,LOCATION_SZONE)),2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectTarget(tp,cm.setfilter,tp,LOCATION_GRAVE,0,1,ct,nil,tp)
	Duel.HintSelection(g)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,g:GetCount(),0,0)
end
function cm.setop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()<=0 then return end
	local ct=math.min(2,(Duel.GetLocationCount(tp,LOCATION_SZONE)))
	if ct<1 then return end
	if g:GetCount()>ct then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		g=g:Select(tp,1,ct,nil)
	Duel.HintSelection(g)
	end
	if Duel.SSet(tp,g)~=0 then
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECKBOT)
		tc:RegisterEffect(e1)
	end
	end
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x666) and not eg:IsContains(e:GetHandler()) end
function cm.filter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x666,1)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and cm.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cm.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x666)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=2
		if ct>0 and Duel.GetMatchingGroupCount(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,0,nil,0x666,1)>0 then
			while ct>0 do
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
				local tc=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,LOCATION_ONFIELD,0,1,1,nil,0x666,1):GetFirst()
				if not tc then break end
				tc:AddCounter(0x666,1)
				ct=ct-1
		end
	end
end