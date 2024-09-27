--晶雪花园
local cm,m,o=GetID()
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,m+19)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,m+18)
	e2:SetCost(cm.tkcost)
	e2:SetTarget(cm.tktg)
	e2:SetOperation(cm.tkop)
	c:RegisterEffect(e2)
	--to field
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(cm.tfcon)
	e3:SetTarget(cm.tftg)
	e3:SetOperation(cm.tfop)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(m,ACTIVITY_SPSUMMON,cm.counterfilter)
end
function cm.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or (c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_WATER))
end
function cm.thfilter(c)
	return c:IsSetCard(0x720) and c:IsType(TYPE_MONSTER)
end
function cm.filter1(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsCode(76200009)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cm.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if tc then
			if tc:IsAbleToHand() and Duel.IsExistingMatchingCard(cm.filter1,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) and Duel.SelectOption(tp,1190,aux.Stringid(m,2))==0 then
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tc)
			else
				Duel.ShuffleDeck(tp)
				Duel.MoveSequence(tc,SEQ_DECKTOP)
				Duel.ConfirmDecktop(tp,1)
			end
		end
	end
end
function cm.tfcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
function cm.tffilter(c,tp)
	return c:IsCode(76200018)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function cm.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.tffilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function cm.tfop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,cm.tffilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
function cm.tkfilter(c,tp)
	return c:IsSetCard(0x720) and c:IsAbleToRemoveAsCost()
end
function cm.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.tkfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.GetCustomActivityCount(m,tp,ACTIVITY_SPSUMMON)==0 end
	local g=Duel.GetMatchingGroup(cm.tkfilter,tp,LOCATION_GRAVE,0,nil)
	local rg=g:Select(tp,1,g:GetCount(),nil)
	local sg=Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(sg)
	--splimit
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cm.splimit)
	Duel.RegisterEffect(e1,tp)
end
function cm.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,76200008,0x720,TYPES_TOKEN_MONSTER+TYPE_TUNER,0,0,3,RACE_FIEND,ATTRIBUTE_WATER) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
end
function cm.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,76200008,0x720,TYPES_TOKEN_MONSTER+TYPE_TUNER,0,0,3,RACE_FIEND,ATTRIBUTE_WATER) then
		local ct=e:GetLabel()
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	if ct>Duel.GetLocationCount(tp,LOCATION_MZONE) then ct=Duel.GetLocationCount(tp,LOCATION_MZONE) end
		while ct>0 do
			local token=Duel.CreateToken(tp,76200008)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			ct=ct-1
		end
		Duel.SpecialSummonComplete()
	end
end
function cm.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_WATER)) and c:IsLocation(LOCATION_EXTRA)
end