--天惠的圣龙 阿斯特利亚
local m=16110036
local cm=_G["c"..m]
function cm.initial_effect(c)
	--Effect 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,1)
	e1:SetValue(cm.aclimit)
	c:RegisterEffect(e1)
	--Effect 2 
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_HAND)
	e5:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0  then return not e:GetHandler():IsPublic() end
				Duel.ConfirmCards(1-tp,e:GetHandler())
				end)
	e5:SetCountLimit(1,m)
	e5:SetTarget(cm.target)
	e5:SetOperation(cm.operation)
	c:RegisterEffect(e5)
	--Effect 3 
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SSET_COST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(cm.costtg)
	e2:SetTargetRange(0x7f,0x7f)
	e2:SetCost(cm.costchk2)
	e2:SetOperation(cm.costop2)
	c:RegisterEffect(e2)
end
--Effect 1
function cm.aclimit(e,re,tp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return false end
	local c=re:GetHandler()
	return not c:IsLocation(LOCATION_SZONE) 
end
--Effect 2
function cm.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cm.filter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingTarget(cm.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,cm.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_NONTUNER)
		e1:SetValue(cm.tnval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(m,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(m,0))
	end
	if tc:GetFlagEffect(m)>0 and c:IsRelateToEffect(e)
	and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end 
end
function cm.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end
--Effect 3 
function cm.costtg(e,te_or_c,tp)
	e:SetLabelObject(te_or_c)
	return true
end
function cm.costchk2(e,te_or_c,tp)
	return true
end
function cm.costop2(e,tp,eg,ep,ev,re,r,rp,te_or_c)
	local rc=e:GetLabelObject()
	Duel.ConfirmCards(1-tp,rc)
	Duel.ConfirmCards(tp,rc)
end
