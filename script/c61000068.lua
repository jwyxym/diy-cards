--混沌之煌炎 加拉哈德
local s,id,o=GetID()
function s.initial_effect(c)
	--synchro summon
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),nil,nil,aux.NonTuner(nil),1,99,s.syncheck)
	c:EnableReviveLimit()
	--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1191)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(1193)
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
end
function s.syncheck(g)
	return g:GetClassCount(Card.GetOriginalRace)==#g or g:GetClassCount(Card.GetOriginalAttribute)==#g
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=c:GetFlagEffect(id)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 and Duel.IsPlayerCanDiscardDeck(tp,1) and ct>0 end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function s.check(c,attr,race)
	return c:IsAttribute(attr) or c:IsRace(race)
end
function s.filter(c,tp)
	return not Duel.IsExistingMatchingCard(s.check,tp,LOCATION_GRAVE,0,1,nil,c:GetAttribute(),c:GetRace()) and c:IsType(TYPE_MONSTER)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetFlagEffect(id)
	local max=math.min(Duel.GetFieldGroupCount(tp,LOCATION_DECK,0),ct)
	if max==0 then return end
	local t={}
	for i=1,max do
		t[i]=max-i+1
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local announce=Duel.AnnounceNumber(tp,table.unpack(t))
	if Duel.DiscardDeck(tp,announce,REASON_EFFECT)>0 then
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,tp)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local tc=g:Select(tp,1,1,nil):GetFirst()
			if tc then
				Duel.MoveSequence(tc,SEQ_DECKTOP)
				Duel.ConfirmDecktop(tp,1)
			end
		end
	end
end
function s.tdfilter(c)
	return c:IsAbleToDeck() and c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
function s.acheck(g,c)
	return g:IsContains(c) and g:GetClassCount(Card.GetAttribute)==#g
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if chk==0 then return g:CheckSubGroup(s.acheck,3,3,c) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:SelectSubGroup(tp,s.acheck,false,3,3,c)
	if #sg==3 then
		Duel.HintSelection(sg)
		Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
	end
	local og=Duel.GetOperatedGroup()
	if #og>0 then
		for tc in aux.Next(og) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetTarget(s.splimit)
			e1:SetLabel(tc:GetCode())
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(e:GetLabel()) and sumtype==SUMMON_TYPE_SYNCHRO
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsSummonType(SUMMON_TYPE_SYNCHRO) then
		local g=c:GetMaterial():Filter(function(c) return not c:IsType(TYPE_TUNER) end,nil)
		local ct=g:GetSum(Card.GetLevel)
		for i=1,ct do
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
		end
	end
end