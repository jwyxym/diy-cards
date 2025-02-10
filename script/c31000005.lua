--
local cm,m,o=GetID()
function cm.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,cm.mfilter,7,3,cm.ovfilter,aux.Stringid(m,0),3,cm.xyzop)
	c:EnableReviveLimit()
	--tograve
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,m)
	e1:SetCost(cm.cost)
	e1:SetCondition(cm.con)
	e1:SetTarget(cm.tg)
	e1:SetOperation(cm.op)
	c:RegisterEffect(e1)
		--tohand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,m+30)
	e2:SetLabel(0)
	e2:SetCost(cm.cost1)
	e2:SetTarget(cm.tg1)
	e2:SetOperation(cm.op1)
	c:RegisterEffect(e2)
end
function cm.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x310) and c:IsRankBelow(5)
end
function cm.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,m)==0 end
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e0:SetTargetRange(1,0)
	e0:SetTarget(cm.splimit)
	e0:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e0,tp)
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=e:GetHandler():GetOverlayCount()
	if chk==0 then return a>0 and Duel.IsPlayerCanDiscardDeck(tp,a) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,a)
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local a=e:GetHandler():GetOverlayCount()
	if a>0 then
		Duel.DiscardDeck(tp,a,REASON_EFFECT)
	end
end
function cm.splimit(e,c)
	return not c:IsRace(RACE_MACHINE)
end
function cm.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
		local e0=Effect.CreateEffect(e:GetHandler())
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e0:SetTargetRange(1,0)
		e0:SetTarget(cm.splimit)
		e0:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e0,tp)
	return true
end
function cm.filter1(c)
	return c:IsSetCard(0x310) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function cm.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(cm.filter1,tp,LOCATION_DECK,0,1,nil) and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
		local sg=e:GetHandler():GetOverlayGroup()
		local g=sg:Select(tp,1,1,nil)
		Duel.SendtoGrave(g,REASON_COST)
	if g:GetFirst():IsRankAbove(1) then e:SetLabel(g:GetFirst():GetRank()) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.filter2(c)
	return c:IsSetCard(0x310) and c:IsAbleToHand()
end
function cm.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(cm.filter1,tp,LOCATION_DECK,0,1,nil) then
		if e:GetLabel()>0 and Duel.IsPlayerCanDiscardDeck(tp,e:GetLabel()) and Duel.SelectYesNo(tp,aux.Stringid(m,2)) then
			Duel.ConfirmDecktop(tp,e:GetLabel())
			local g=Duel.GetDecktopGroup(tp,e:GetLabel())
			if g:GetCount()>0 then
				Duel.DisableShuffleCheck()
				if g:IsExists(cm.filter2,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(m,3)) then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
					local sg=g:FilterSelect(tp,cm.filter2,1,1,nil)
					Duel.SendtoHand(sg,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,sg)
					Duel.ShuffleHand(tp)
					g:Sub(sg)
				end
				Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
			end
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,cm.filter1,tp,LOCATION_DECK,0,1,1,nil)
			if g:GetCount()>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end
