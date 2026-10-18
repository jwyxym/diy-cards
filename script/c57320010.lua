--威风的行军
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,57320080)
	--发动
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--衍生物
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(3)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
function s.rmfilter(c)
	return aux.IsCodeListed(c,57320080) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=g:Select(tp,1,1,nil)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsControler(tp) and c:IsPreviousControler(tp)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil):GetFirst()
	if not tc then return end
    Duel.HintSelection(Group.FromCards(tc))
	if Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)~=0 and tc:IsLocation(LOCATION_GRAVE)
    	and Duel.IsPlayerCanSpecialSummonMonster(tp,57320100,0,TYPES_TOKEN_MONSTER+TYPE_TUNER,1500,1500,2,RACE_WARRIOR,ATTRIBUTE_DARK)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.BreakEffect()
        local token=Duel.CreateToken(tp,57320100)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetRange(LOCATION_MZONE)
			e1:SetAbsoluteRange(tp,1,0)
			e1:SetTarget(s.splimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
        end
		Duel.SpecialSummonComplete()
	end
end
function s.splimit(e,c)
	return not c:IsRace(RACE_WARRIOR)
end