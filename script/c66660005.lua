--幻星集 教皇
local m=66660005
local cm=_G["c"..m]
Duel.LoadScript("c666Tarrow.lua")
function cm.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	xiaoye.PendulumScale(c)
	xiaoye.CannotBeMaterial(c)
--set
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,m+4)
	e3:SetCost(xiaoye.PendulumEffectCost)
	e3:SetTarget(cm.tg1)
	e3:SetOperation(cm.op1)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_LEAVE_GRAVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_EXTRA)
	e4:SetCountLimit(1,m+5)
	e4:SetCondition(cm.con2)
	e4:SetTarget(cm.tg2)
	e4:SetOperation(cm.op2)
	c:RegisterEffect(e4)
--draw
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DRAW+CATEGORY_LEAVE_GRAVE+CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,m+6)
	e5:SetCost(cm.cost3)
	e5:SetTarget(cm.tg3)
	e5:SetOperation(cm.op3)
	c:RegisterEffect(e5)
end
function cm.filter1(c,tp)
	return c:IsSetCard(0x666) and c:GetType()==TYPE_SPELL and c:CheckUniqueOnField(tp)
end
function cm.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter1,tp,LOCATION_DECK,0,1,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function cm.op1(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) and Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=Duel.SelectMatchingCard(tp,cm.filter1,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		if tc then
			Duel.SSet(tp,tc)
		end
	end
end
function cm.filter2(c,tp)
	return c:IsSetCard(0x666) and c:IsType(TYPE_SPELL) and c:CheckUniqueOnField(tp)
end
function cm.con2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup() end
function cm.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter2,tp,LOCATION_GRAVE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE-LOCATION_FZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nill,1,tp,0)
end
function cm.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)~=0 then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,cm.filter2,tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
		if tc then
			if Duel.SSet(tp,tc,tp,false)~=0 then
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
end
function cm.filter3(c,e,tp)
	return c:IsSetCard(0x666) and c:IsAbleToRemoveAsCost() and not c:IsCode(m)
end
function cm.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter3,tp,LOCATION_GRAVE,0,1,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cm.filter3,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function cm.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cm.op3(e,tp,eg,ep,ev,re,r,rp,c)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end