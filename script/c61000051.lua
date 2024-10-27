--云剑·崩雪
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1,id)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.sthcon)
	e2:SetTarget(s.sthtg)
	e2:SetOperation(s.sthop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.chk)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.chk(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentChain()>3 then
		Duel.RegisterFlagEffect(rp,id+o*10000,RESET_PHASE+PHASE_END,0,2)
	end
end
function s.sthcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
		and Duel.GetFlagEffect(tp,id+o*10000)>0
end
function s.sthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.sthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetCurrentChain()
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and Duel.IsPlayerCanDiscardDeck(tp,ct) end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	if re:GetHandler():IsSetCard(0xa7c0) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetCurrentChain()
	if Duel.DiscardDeck(tp,ct,REASON_EFFECT)~=0 then
		local g=Duel.GetOperatedGroup()
		local dam=0
		for i=1,ev do
			local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
			if te:GetHandler():IsSetCard(0xa7c0) then
				dam=dam+400
			end
		end
		if g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)~=0
			and dam~=0
			and e:GetLabel()==1
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re:GetHandler():IsSetCard(0xa7c0) and c:IsAbleToHand()
		and Duel.GetFlagEffect(tp,id)==0
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end