--传达的乐音:EXIST
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)
	local eff=Effect.CreateEffect(c)
	eff:SetType(EFFECT_TYPE_FIELD)
	eff:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	eff:SetRange(LOCATION_MZONE)
	eff:SetCode(EFFECT_ACTIVATE_COST)
	eff:SetCost(s.costchk)
	eff:SetOperation(s.costop)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.eftg)
	e4:SetLabelObject(eff)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_HANDES+CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(2,id+id)
	e5:SetCondition(s.discardcon)
	e5:SetTarget(s.discardtg)
	e5:SetOperation(s.discardop)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,4))
	e6:SetCategory(CATEGORY_REMOVE)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetCountLimit(1,id+id+id)
	e6:SetTarget(s.thtg)
	e6:SetOperation(s.thop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e7)
end
function s.costchk(e,te_or_c,tp)
	local ct=Duel.GetFlagEffect(tp,id)
	return Duel.CheckLPCost(tp,ct*100)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,100)
end
function s.eftg(e,c)
	return c:GetMutualLinkedGroupCount()>0 and c:IsType(TYPE_LINK)
end
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return rc~=e:GetHandler() and rc:IsSetCard(0xf00)
end
function s.alllinkfilter(c)
	return c:GetMutualLinkedGroupCount()>0
end
function s.discardcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.alllinkfilter,tp,LOCATION_MZONE,0,nil)
	return #g==Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
function s.discardtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.discardop(e,tp,eg,ep,ev,re,r,rp)
	if  Duel.GetMatchingGroupCount(Card.IsDiscardable,1-tp,0,LOCATION_HAND,nil,REASON_EFFECT)>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,3)) then
		Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD,nil)
	else
		Duel.SetLP(1-tp,Duel.GetLP(1-tp)-500)
	end
end
function s.tgfilter(c)
	return c:IsSetCard(0xf09) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
