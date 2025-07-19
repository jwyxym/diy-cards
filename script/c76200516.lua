--龙爪如湖光
function c76200516.initial_effect(c)
	aux.AddCodeList(c,76200500)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,76200516)
	e1:SetCondition(c76200516.spcon)
	e1:SetTarget(c76200516.sptg)
	e1:SetOperation(c76200516.spop)
	c:RegisterEffect(e1)
	--synchro level
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SYNCHRO_LEVEL)
	e2:SetValue(c76200516.slevel)
	c:RegisterEffect(e2)
end
function c76200516.cfilter(c)
	return c:IsFaceup() and ((c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevelAbove(8)) or c:IsCode(76200500))
end
function c76200516.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c76200516.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c76200516.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsFaceup()
end
function c76200516.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c76200516.spfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(c76200516.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c76200516.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c76200516.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(math.ceil(tc:GetAttack()/2))
			tc:RegisterEffect(e1)
		end
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
	end
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetTarget(c76200516.splimit)
	Duel.RegisterEffect(e3,tp)
end
function c76200516.splimit(e,c)
	return not c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLocation(LOCATION_EXTRA)
end
function c76200516.slevel(e,c)
	local lv=aux.GetCappedLevel(e:GetHandler())
	if c:IsRace(RACE_DRAGON) then  
		return (lv+1<<16)+lv
	else 
		return lv 
	end 
end





