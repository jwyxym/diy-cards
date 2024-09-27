--Sneak·土噬吞食虫
local m=52500003
local cm=_G["c"..m]
Duel.LoadScript("Sneak.lua")
function cm.initial_effect(c)
	sk.SPSummon(c,m)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCountLimit(1,m*2)
	e1:SetCost(sk.fcost)
	e1:SetTarget(cm.postg)
	e1:SetOperation(cm.posop)
	c:RegisterEffect(e1)
end
function cm.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function cm.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(cm.posfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
function cm.posop(e,tp,eg,ep,ev,re,r,rp)
	local g2=Duel.GetMatchingGroup(cm.posfilter,tp,0,LOCATION_MZONE,nil)
	if g2:GetCount()>0 then
		if Duel.ChangePosition(g2,POS_FACEDOWN_DEFENSE) and e:GetHandler():IsCanTurnSet() and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
			Duel.BreakEffect()
			Duel.ChangePosition(e:GetHandler(),POS_FACEDOWN_DEFENSE)
		end
	end
end
