--神帝的坏世
if not pcall(function() require("expansions/script/c16199990") end) then require("script/c16199990") end
local m=16110013
local cm=_G["c"..m]
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,m+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(cm.cost)
	e2:SetTarget(cm.target)
	e2:SetOperation(cm.operation)
	c:RegisterEffect(e2)
	--
	local e3=rsef.QO(c,EVENT_FREE_CHAIN,{m,1},nil,nil,nil,LOCATION_GRAVE,nil,cm.cost2,nil,cm.sumop)
end
--search
function cm.cfilter(c)
	return c:IsSetCard(0xcc5) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsPublic()
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,cm.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function cm.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_EXTRA,0,1,nil,0xcc5) and e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_EXTRA,0,1,1,nil,0xcc5)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleExtra(tp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function cm.filter(c)
	return c:IsSetCard(0xcc5) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cm.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function cm.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(cm.regop)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetLabel(Duel.GetTurnCount())
	e2:SetCondition(cm.damcon2)
	e2:SetOperation(cm.damop)
	e2:SetReset(RESET_PHASE+PHASE_END,2)
	e2:SetLabelObject(e1)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CHANGE_DAMAGE)
	e3:SetTargetRange(1,0)
	e3:SetValue(cm.damval2)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD+EVENT_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e4:SetCondition(cm.damcon)
	Duel.RegisterEffect(e4,tp)
end
function cm.regfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(cm.regfilter,1,nil,tp) then
		e:SetLabel(1)
	end
end
function cm.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()~=1 and Duel.GetTurnCount()>e:GetLabel()
end
function cm.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetLP(tp,0)
end
function cm.damval2(e,re,val,r,rp,rc)
	local c=e:GetHandler()
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 and Duel.GetFlagEffect(tp,m)<=1 then
		Duel.RegisterFlagEffect(e:GetHandlerPlayer(),m,RESET_PHASE+PHASE_END,0,1)
		return 0
	end
	return val
end
function cm.damcon(e)
	return Duel.GetFlagEffect(tp,m)<=1
end