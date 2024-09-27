--幻星集之旅
local m=66660032
local cm=_G["c"..m]
function cm.initial_effect(c)
	c:EnableCounterPermit(0x666)
--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,m+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(cm.ctcon)
	e2:SetOperation(cm.ctop)
	c:RegisterEffect(e2)
	--remain field
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_REMAIN_FIELD)
	c:RegisterEffect(e3)
	--Destroy
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetLabel(0)
	e4:SetCondition(cm.con)
	e4:SetCost(cm.cost)
	e4:SetOperation(cm.op)
	c:RegisterEffect(e4)
end
function cm.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_PZONE) and c:IsPreviousControler(tp) and c:IsPreviousSetCard(0x666)
end
function cm.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.cfilter,1,nil,tp)
end
function cm.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x666,1)
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetCounter(0x666)
	if ct==0 then return false end
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x666,ct,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x666,ct,REASON_COST)
	e:SetLabel(ct)
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local a=e:GetLabel()
	local ct=0
	while a>=2 do
	a=a-2
	ct=ct+1
	end
	if ct>4 then ct=4 end
	local g=Duel.GetMatchingGroup(cm.thfilter,tp,LOCATION_DECK,0,nil)
	if g then
	local gt=g:GetClassCount(Card.GetAttribute)
	if ct>gt then ct=gt end
	if ct>0 then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local rg=g:SelectSubGroup(tp,aux.dabcheck,false,ct,ct,e,tp)
	if rg:GetCount()>0 then
		if Duel.SendtoHand(rg,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,rg)
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
	end
	end
end
function cm.thfilter(c)
	return c:IsSetCard(0x666) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end