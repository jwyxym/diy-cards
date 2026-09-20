--妖精使 守护仙女
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(function(c) return c:IsRace(RACE_BEAST+RACE_PLANT+RACE_FAIRY) end),1)
	aux.AddCodeList(c,25862681)
	--①
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--② attack restriction
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.atlimit)
	c:RegisterEffect(e2)
	--② cannot remove
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_REMOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(s.rmlimit)
	c:RegisterEffect(e3)
	--③
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o*100)
	e4:SetTarget(s.lvtg)
	e4:SetOperation(s.lvop)
	c:RegisterEffect(e4)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.thfilter(c,e,tp)
	return aux.IsCodeListed(c,25862681) and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g==0 then return end
	local tc=g:GetFirst()
	local b1=tc:IsAbleToHand()
	local b2=tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if b1 and b2 then
		local op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
		if op==0 then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif b1 then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	elseif b2 then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.deffilter(c,def)
	return c:IsFaceup() and c:IsDefenseAbove(def)
end
function s.atlimit(e,c)
	local tp=e:GetHandlerPlayer()
	return c:IsFaceup() and c:IsControler(tp) and Duel.IsExistingMatchingCard(s.deffilter,tp,LOCATION_MZONE,0,1,c,c:GetDefense())
end
function s.rmlimit(e,c,rp,r,re)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp) and c:IsOnField() and c:IsFaceup()
		and r&REASON_EFFECT~=0 and r&REASON_REDIRECT==0 and rp==1-tp
		and not Duel.IsExistingMatchingCard(s.deffilter,tp,LOCATION_MZONE,0,1,c,c:GetDefense())
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
	local lv=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(lv+1)
	c:RegisterEffect(e1)
end
