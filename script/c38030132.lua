--异晶手
function c38030132.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,38030132)
	e1:SetCost(c38030132.thcost)
	e1:SetTarget(c38030132.thtg)
	e1:SetOperation(c38030132.thop)
	c:RegisterEffect(e1)
	--spsummon-self
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38030132,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,38030132+1)
	e2:SetCondition(c38030132.spcon)
	e2:SetTarget(c38030132.sptg)
	e2:SetOperation(c38030132.spop)
	c:RegisterEffect(e2)
	--
	if not c38030132.global_check then
		c38030132.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		ge1:SetTargetRange(LOCATION_OVERLAY,LOCATION_OVERLAY)
		ge1:SetTarget(aux.TargetBoolFunction(Card.IsCode,38030132))
		ge1:SetValue(LOCATION_REMOVED)
		Duel.RegisterEffect(ge1,0)
	end
end
function c38030132.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function c38030132.thfilter(c)
	return c:IsSetCard(0x175) and c:IsType(TYPE_SPELL+TYPE_TRAP) and (c:IsAbleToHand() or c:IsSSetable())
end
function c38030132.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c38030132.thfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c38030132.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local tc=Duel.SelectMatchingCard(tp,c38030132.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		if tc:IsAbleToHand() and (not tc:IsSSetable() or Duel.SelectOption(tp,1190,1153)==0) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SSet(tp,tc)
		end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c38030132.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c38030132.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_EARTH)) and c:IsLocation(LOCATION_EXTRA)
end
function c38030132.cfilter(c)
	return c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
function c38030132.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c38030132.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c38030132.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c38030132.spop(e,tp,eg,ep,ev,re,r,rp)
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
