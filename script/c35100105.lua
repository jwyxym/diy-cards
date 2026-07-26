--异质绝望 塔和最中
local m=35100105
local cm=_G["c"..m]
function cm.initial_effect(c)
	--spsummon
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(m,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,m)
	e0:SetCost(cm.spcost)
	e0:SetTarget(cm.sptg)
	e0:SetOperation(cm.spop)
	c:RegisterEffect(e0)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,3))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,m+1)
	e1:SetCost(cm.accost)
	e1:SetTarget(cm.actg)
	e1:SetOperation(cm.acop)
	c:RegisterEffect(e1)
end
function cm.cfilter(c)
	return c:IsRace(RACE_WARRIOR) or (c:IsAttack(0) and c:IsDefense(1800) and c:IsLevel(3)) and c:IsAbleToRemoveAsCost()
end
function cm.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(cm.cfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cm.cfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		Duel.BreakEffect()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(1)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(500)
		c:RegisterEffect(e2)
	end
end

function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp 
end
function cm.accost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function cm.acfilter(c,tp)
	return c:IsSetCard(0xa91) and c:IsType(TYPE_FIELD+TYPE_CONTINUOUS) and c:GetActivateEffect():IsActivatable(tp,true,true) and c:IsType(TYPE_SPELL)
end
function cm.thfilter(c,tp)
	return c:IsSetCard(0xa91) and c:IsAbleToHand() and (c:GetType()==TYPE_SPELL or c:IsType(TYPE_QUICKPLAY))
end
function cm.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(cm.acfilter,tp,LOCATION_DECK,0,1,nil,tp)
	local b2=Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_DECK,0,1,nil,tp)
	local op=0
	if chk==0 then return b1 or b2 end
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(m,1),aux.Stringid(m,2))
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(m,1))
	else op=Duel.SelectOption(tp,aux.Stringid(m,2))+1 end
	if op==0 then
		if not Duel.CheckPhaseActivity() then e:SetLabel(1) else e:SetLabel(0) end
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		e:SetLabel(2)
	end
end
function cm.acop(e,tp,eg,ep,ev,re,r,rp)  
	if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,m,RESET_CHAIN,0,1) end
	if e:GetLabel()~=2 then 
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(m,1))
		local tc=Duel.SelectMatchingCard(tp,cm.acfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		Duel.ResetFlagEffect(tp,m)
		if tc and tc:IsType(TYPE_FIELD) then
			local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
			if fc then
				Duel.SendtoGrave(fc,REASON_RULE)
				Duel.BreakEffect()
			end
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			local te=tc:GetActivateEffect()
			te:UseCountLimit(tp,1,true)
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
		else
			local te=tc:GetActivateEffect()
			if not te:IsActivatable(tp,true,true) then return end 
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			te:UseCountLimit(tp,1,true)
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(m,2))
		local tc=Duel.SelectMatchingCard(tp,cm.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		if tc then
			Duel.SendtoHand(tc,tp,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		end
	end
	e:SetLabel(0)
end