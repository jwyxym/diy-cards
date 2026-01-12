--忘泉贪骸
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.drcon)
	e2:SetCost(s.cost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SUMMON,s.counterfilter)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
function s.counterfilter(c)
	return c:IsSetCard(0xd87)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SUMMON)==0
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
		and (Duel.GetActivityCount(tp,ACTIVITY_SUMMON)+Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON))<=1 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e2,tp)
	if (Duel.GetActivityCount(tp,ACTIVITY_SUMMON)+Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON))~=0 then
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_SUMMON)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e3:SetTargetRange(1,0)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		Duel.RegisterEffect(e4,tp)
	else
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CANNOT_SUMMON)
		e3:SetTargetRange(1,0)
		e3:SetLabel(s.getsummoncount(tp))
		e3:SetTarget(s.splimit)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		Duel.RegisterEffect(e4,tp)
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_FIELD)
		e5:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
		e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e5:SetTargetRange(1,0)
		e5:SetLabel(s.getsummoncount(tp))
		e5:SetValue(s.countval)
		e5:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e5,tp)
	end
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xd87)
end
function s.getsummoncount(tp)
	return Duel.GetActivityCount(tp,ACTIVITY_SUMMON)+Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return s.getsummoncount(sump)>e:GetLabel()
end
function s.countval(e,re,tp)
	if s.getsummoncount(tp)>e:GetLabel() then return 0 else return 1 end
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		and s.cost(e,tp,eg,ep,ev,re,r,rp,chk) end
	s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
end
function s.thfilter(c)
	return c:IsSetCard(0xd88) and c:IsType(TYPE_QUICKPLAY) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()==0 then return end
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0):Select(tp,1,1,nil)
	if g:GetCount()>0 then
		Duel.BreakEffect()
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()) and r==REASON_FUSION
		and c:GetReasonCard():IsSetCard(0xd87)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end