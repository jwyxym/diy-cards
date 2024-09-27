--妖精骑士 崔斯坦
function c72600201.initial_effect(c) 
	aux.AddCodeList(c,72600201) 
	--link summon
	aux.AddLinkProcedure(c,nil,2,2,c72600201.lcheck)
	c:EnableReviveLimit() 
	--code
	aux.EnableChangeCode(c,72600200,LOCATION_MZONE+LOCATION_GRAVE) 
	--cannot target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(aux.tgoval) 
	e1:SetCondition(function(e) 
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsType(TYPE_TOKEN) end,tp,LOCATION_MZONE,0,1,nil) end)
	c:RegisterEffect(e1)
	--battle target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(aux.imval1) 
	e1:SetCondition(function(e) 
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsType(TYPE_TOKEN) end,tp,LOCATION_MZONE,0,1,nil) end)
	c:RegisterEffect(e1) 
	--special summon
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c72600201.spcon)
	e2:SetTarget(c72600201.sptg)
	e2:SetOperation(c72600201.spop)
	c:RegisterEffect(e2)
end
function c72600201.lcheck(g)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_TOKEN)  
end
function c72600201.cfilter(c,lg)
	return lg:IsContains(c) and c:IsFaceup() and c:IsType(TYPE_TOKEN)
end
function c72600201.spcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(c72600201.cfilter,1,nil,lg)
end
function c72600201.filter(c,e,tp)
	return c:IsCode(72600200) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function c72600201.sptg(e,tp,eg,ep,ev,re,r,rp,chk) 
	if chk==0 then return Duel.IsExistingMatchingCard(c72600201.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end 
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c72600201.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.SelectMatchingCard(tp,c72600201.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst() 
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2) 
		Duel.SpecialSummonComplete() 
	end 
end




