--昏暗的沼泽
function c76200511.initial_effect(c)
	aux.AddCodeList(c,76200500)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN) 
	e1:SetCountLimit(1,76200511+EFFECT_COUNT_CODE_OATH) 
	e1:SetOperation(c76200511.activate)
	c:RegisterEffect(e1)
	--activate limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(function(e)
	local tp=e:GetHandlerPlayer() 
	return Duel.IsExistingMatchingCard(function(c) return (c:IsCode(76200500) or aux.IsCodeListed(c,76200500)) and c:IsFaceup() end,tp,LOCATION_MZONE,0,1,nil) and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) end)
	e2:SetValue(aux.TRUE) 
	c:RegisterEffect(e2) 
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(76200511,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,16200511)
	e3:SetCondition(c76200511.spcon)
	e3:SetCost(c76200511.spcost) 
	e3:SetTarget(c76200511.sptg)
	e3:SetOperation(c76200511.spop)
	c:RegisterEffect(e3)
end
function c76200511.tgfilter(c,tp) 
	if Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) end,tp,LOCATION_MZONE,0,1,nil) then 
		return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand() 
	else 
		return c:IsCode(76200500) and c:IsAbleToHand() 
	end 
end
function c76200511.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c76200511.tgfilter,tp,LOCATION_DECK,0,nil,tp)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(76200511,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,tp,REASON_EFFECT) 
		Duel.ConfirmCards(1-tp,sg) 
	end
end
function c76200511.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function c76200511.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function c76200511.spfilter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function c76200511.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c76200511.cfilter,1,nil) and rp==tp
end
function c76200511.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=eg:Filter(c76200511.cfilter,nil):GetFirst():GetMaterial()
	if chkc then return mg:IsContains(chkc) and c76200511.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and mg:IsExists(c76200511.spfilter,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=mg:FilterSelect(tp,c76200511.spfilter,1,1,nil,e,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c76200511.spop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end





