--巨掌王-熔岩
function c38030137.initial_effect(c)
	aux.AddCodeList(c,38030130)
	--spsummon-self
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38030137,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,38030137)
	e1:SetCost(c38030137.cost)
	e1:SetTarget(c38030137.sptg)
	e1:SetOperation(c38030137.spop)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38030137,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,38030137+1)
	e2:SetCost(c38030137.cost)
	e2:SetTarget(c38030137.thtg)
	e2:SetOperation(c38030137.thop)
	c:RegisterEffect(e2)
	--xyz
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38030137,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,38030137+2)
	e3:SetCost(c38030137.cost)
	e3:SetOperation(c38030137.xyzop)
	c:RegisterEffect(e3)
end
function c38030137.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.PayLPCost(tp,1000)
end
function c38030137.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c38030137.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
function c38030137.thfilter(c)
	return c:IsCode(38030130,38030132,38030134) and c:IsAbleToHand()
end
function c38030137.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c38030137.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:GetCount()>=3 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function c38030137.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c38030137.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sg=g:Select(tp,3,3,nil)
		Duel.ConfirmCards(1-tp,sg)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tg=sg:Select(tp,1,1,nil)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c38030137.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c38030137.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_EARTH)) and c:IsLocation(LOCATION_EXTRA)
end
function c38030137.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DOUBLE_XMATERIAL)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetValue(38030137)
		e1:SetTarget(c38030137.sxyzfilter)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
function c38030137.sxyzfilter(e,c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsSetCard(0x48)
end
