--深池方阵战士
function c31280314.initial_effect(c)
	--手卡特召
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,31280314)
	e1:SetTarget(c31280314.target)
	e1:SetOperation(c31280314.operation)
	c:RegisterEffect(e1)
    --攻守变化
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c31280314.condition)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
function c31280314.spfilter(c,e,tp,check)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.DrytronSpSummonType(c)) and ((check and c:IsSetCard(0xca3) and not c:IsType(TYPE_RITUAL)) or c:IsCode(31280314))
end
function c31280314.checkfilter(c)
	return c:IsPublic() and c:IsRace(RACE_DRAGON)
end
function c31280314.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
    local check=Duel.IsExistingMatchingCard(c31280314.checkfilter,tp,LOCATION_HAND,0,1,nil)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31280314.spfilter(chkc,e,tp,check) end
	if chk==0 then 
    return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and Duel.IsExistingTarget(c31280314.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,check) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c31280314.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,check)
	g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
function c31280314.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
    local check=Duel.IsExistingMatchingCard(c31280314.checkfilter,tp,LOCATION_HAND,0,1,nil)
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and tc:IsCanBeSpecialSummoned(e,0,tp,false,aux.DrytronSpSummonType(tc))
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
		local g=Group.FromCards(c,tc)
        if Duel.SpecialSummon(g,0,tp,tp,false,aux.DrytronSpSummonType(tc),POS_FACEUP)~=0 and aux.DrytronSpSummonType(tc) then
			tc:CompleteProcedure()
        end   
	end        
	--自肃        
	local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_EXTRA_MATERIAL)
    e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetTargetRange(LOCATION_ONFIELD+LOCATION_HAND,0)
    e1:SetTarget(function(_,c)
        return c:IsSetCard(0xca3) and c:IsType(TYPE_MONSTER)
    end)
    e1:SetValue(1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetTargetRange(LOCATION_ONFIELD+LOCATION_HAND,0)
    e2:SetTarget(function(_,c)
        return not c:IsSetCard(0xca3)
    end)
    e2:SetValue(1)
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2,tp)
        
    local e3=e2:Clone()
    e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    Duel.RegisterEffect(e3,tp)
end
function c31280314.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xca3) and c:IsType(TYPE_MONSTER)
end
function c31280314.condition(e)
	return Duel.IsExistingMatchingCard(c31280314.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,e:GetHandler())
end