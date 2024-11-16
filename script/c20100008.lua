--PLU-Infection Black Visitation
function c20100008.initial_effect(c)
	c:SetUniqueOnField(1,0,20100008)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,20100008+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c20100008.target)
	e1:SetOperation(c20100008.operation)
	e1:SetCategory(CATEGORY_REMOVE)
	c:RegisterEffect(e1)
	--setcard
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_EXTRA,LOCATION_EXTRA)
	e2:SetCode(EFFECT_ADD_SETCODE)
	e2:SetValue(0xb28)
	c:RegisterEffect(e2)
	--disable summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c20100008.sumlimit)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e5)
end
function c20100008.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0xb28)
end
function c20100008.filter(c)
	return c:IsSetCard(0xb28) and c:IsType(TYPE_CONTINUOUS) and not c:IsCode(20100008) and c:IsAbleToRemove()
end
function c20100008.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.IsExistingMatchingCard(c20100008.filter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(20100008,0)) then
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	end
end
function c20100008.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c20100008.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) and c:IsRelateToEffect(e) then
		local code=tc:GetCode()
		c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD,1)
	end
end