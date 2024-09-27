--梅柳齐娜·翁蒂娜
function c76200501.initial_effect(c)
	aux.AddCodeList(c,76200500)
	--SpecialSummon
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION) 
	e1:SetRange(LOCATION_HAND) 
	e1:SetCountLimit(1,76200501) 
	e1:SetCost(c76200501.cost)
	e1:SetTarget(c76200501.sptg) 
	e1:SetOperation(c76200501.spop) 
	c:RegisterEffect(e1) 
	--nontuner
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_NONTUNER)
	e1:SetValue(function(e,c)
	return e:GetHandler():IsControler(c:GetControler()) end)
	c:RegisterEffect(e1) 
	--search
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH) 
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,16200501)
	e2:SetCondition(c76200501.thcon) 
	e2:SetCost(c76200501.cost)
	e2:SetTarget(c76200501.thtg)
	e2:SetOperation(c76200501.thop)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(76200501,ACTIVITY_SPSUMMON,c76200501.counterfilter)
end
function c76200501.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or (c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT))
end
function c76200501.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(76200501,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT)) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end 
function c76200501.stgfil(c,e,tp) 
	return c:IsAbleToGraveAsCost() and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON) and Duel.IsExistingMatchingCard(c76200501.spfil,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end 
function c76200501.spfil(c,e,tp,sc) 
	return c:GetLevel()+e:GetHandler():GetLevel()==sc:GetLevel() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsCode(76200500) or aux.IsCodeListed(c,76200500))
end 
function c76200501.sptg(e,tp,eg,ep,ev,re,r,rp,chk) 
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.IsExistingMatchingCard(c76200501.stgfil,tp,LOCATION_EXTRA,0,1,nil,e,tp) end 
	local tc=Duel.SelectMatchingCard(tp,c76200501.stgfil,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst() 
	e:SetLabelObject(tc) 
	Duel.SendtoGrave(tc,REASON_COST) 
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_HAND) 
end
function c76200501.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc and Duel.IsExistingMatchingCard(c76200501.spfil,tp,LOCATION_DECK,0,1,nil,e,tp,tc) and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133) then 
		local sg=Duel.SelectMatchingCard(tp,c76200501.spfil,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc)
		sg:AddCard(c) 
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end 
end 
function c76200501.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end 
function c76200501.thfilter(c)
	return (c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.IsCodeListed(c,76200500)) and c:IsAbleToHand() 
end
function c76200501.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c76200501.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c76200501.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c76200501.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end 







