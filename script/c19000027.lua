--狐火太刀
function c19000027.initial_effect(c)
	--splimit
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(c19000027.splimit)
	c:RegisterEffect(e0)
	--spsummon self
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19000027,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,19000027)
	e1:SetTarget(c19000027.spstg)
	e1:SetOperation(c19000027.spsop)
	c:RegisterEffect(e1)
	--destroy&ATK up
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19000027,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetTarget(c19000027.destg1)
	e2:SetOperation(c19000027.desop1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e3:SetDescription(aux.Stringid(19000027,2))
	e3:SetTarget(c19000027.destg2)
	e3:SetOperation(c19000027.desop2)
	c:RegisterEffect(e3)
end
function c19000027.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
function c19000027.filter(c,tp)
	return c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_FIRE) and Duel.GetMZoneCount(tp,c)>0
end
function c19000027.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c19000027.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,c,tp)
	if chk==0 then return #g>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c19000027.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,c19000027.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,aux.ExceptThisCard(e),tp)
	if Duel.Destroy(g,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c19000027.desfilter1(c)
	return c:IsFaceupEx() and not c:IsCode(19000027) and c:IsAttribute(ATTRIBUTE_FIRE)
end
function c19000027.destg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19000027.desfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
end
function c19000027.desop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,c19000027.desfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		if Duel.Destroy(g,REASON_EFFECT)>0 then
			local tc=g:GetFirst()
			local atk=tc:GetAttack()
			local c=e:GetHandler()
			if c:IsFaceup() and c:IsRelateToEffect(e) and atk>0 then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(atk)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
				c:RegisterEffect(e1)
			end
		end
	end
end
function c19000027.desfilter2(c)
	return c:IsFaceupEx() and not c:IsCode(19000027) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemove()
end
function c19000027.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19000027.desfilter2,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
function c19000027.desop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c19000027.desfilter2,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
			local tc=g:GetFirst()
			local atk=tc:GetAttack()
			local c=e:GetHandler()
			if c:IsFaceup() and c:IsRelateToEffect(e) and atk>0 then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(atk)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
				c:RegisterEffect(e1)
			end
		end
	end
end