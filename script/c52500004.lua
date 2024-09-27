--Sneak·毒气轰炸机
local m=52500004
local cm=_G["c"..m]
Duel.LoadScript("Sneak.lua")
function cm.initial_effect(c)
	--normal XYZ summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ROCK),7,2)
	--XYZ summon using set monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(cm.xyzcon)
	e1:SetTarget(cm.xyztg)
	e1:SetOperation(cm.xyzop)
	e1:SetValue(SUMMON_TYPE_XYZ)
	e1:SetTargetRange(POS_FACEDOWN_DEFENSE,0)
	c:RegisterEffect(e1)
	--damage
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCountLimit(1,m)
	e2:SetCost(sk.xcost)
	e2:SetTarget(cm.dmtg)
	e2:SetOperation(cm.dmop)
	c:RegisterEffect(e2)
	--negate
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,m*2)
	e3:SetCondition(cm.discon)
	e3:SetCost(sk.xcost)
	e3:SetTarget(cm.distg)
	e3:SetOperation(cm.disop)
	c:RegisterEffect(e3)
end
function cm.xyzfilter(c)
	return c:IsFacedown() and c:IsSetCard(0x520) and c:IsCanBeXyzMaterial(nil) and not c:IsType(TYPE_XYZ)
end
function cm.xyzcheck(sg,tp)
	return sg:FilterCount(cm.xyzfilter,nil)==#sg and Duel.GetMZoneCount(tp,sg)>0
end
function cm.xyzcon(e,c)
	if c==nil then return true end
	local tp=c:GetOwner()
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(cm.xyzcheck,2,2,tp)
end
function cm.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
	local sg=g:SelectSubGroup(tp,cm.xyzcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function cm.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
	local mg=e:GetLabelObject()
	local sg=Group.CreateGroup()
	local tc=mg:GetFirst()
	while tc do
		local sg1=tc:GetOverlayGroup()
		sg:Merge(sg1)
		tc=mg:GetNext()
	end
	Duel.SendtoGrave(sg,REASON_RULE)
	c:SetMaterial(mg)
	Duel.Overlay(c,mg)
	mg:DeleteGroup()
	Duel.ConfirmCards(1-tp,c)
end
function cm.ffilter(c)
	return c:IsFacedown() and c:IsAbleToGrave()
end
function cm.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local num=Duel.GetMatchingGroupCount(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,num*300)
end
function cm.dmop(e,tp,eg,ep,ev,re,r,rp)
	local num=Duel.GetMatchingGroupCount(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if Duel.Damage(1-tp,num*300,REASON_EFFECT) then
		if Duel.IsExistingMatchingCard(cm.ffilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and e:GetHandler():IsCanTurnSet() and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=Duel.SelectMatchingCard(tp,cm.ffilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			if #g and Duel.SendtoGrave(g,REASON_EFFECT) then Duel.ChangePosition(e:GetHandler(),POS_FACEDOWN_DEFENSE) end
		end
	end
end
function cm.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and rp==1-tp
end
function cm.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function cm.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		if Duel.Destroy(eg,REASON_EFFECT) then
			if Duel.IsExistingMatchingCard(cm.ffilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and e:GetHandler():IsCanTurnSet() and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
				local g=Duel.SelectMatchingCard(tp,cm.ffilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
				if #g and Duel.SendtoGrave(g,REASON_EFFECT) then Duel.ChangePosition(e:GetHandler(),POS_FACEDOWN_DEFENSE) end
			end
		end
	end
end
