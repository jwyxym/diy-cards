--
function c19990034.initial_effect(c)
	c:SetSPSummonOnce(19990034)
	c:SetUniqueOnField(1,0,19990034)
	--synchro summon
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	--pendulum summon
	aux.EnablePendulumAttribute(c,false)
	--cannot be target
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--mat check
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c19990034.matcheck)
	c:RegisterEffect(e1)
	--act limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c19990034.regcon)
	e2:SetOperation(c19990034.regop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--pendulum
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19990034,4))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCondition(c19990034.pencon)
	e3:SetTarget(c19990034.pentg)
	e3:SetOperation(c19990034.penop)
	c:RegisterEffect(e3)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetDescription(aux.Stringid(19990034,0))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_RELEASE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c19990034.thcon1)
	e4:SetTarget(c19990034.destg)
	e4:SetOperation(c19990034.desop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_REMOVE)
	e5:SetCondition(c19990034.thcon2)
	c:RegisterEffect(e5)
	--spsummon
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(19990034,0))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_PZONE)
	e6:SetCountLimit(1,19990034)
	e6:SetCost(c19990034.spscost)
	e6:SetTarget(c19990034.spstg)
	e6:SetOperation(c19990034.spsop)
	c:RegisterEffect(e6)
end
function c19990034.matcheck(e,c)
	local g=c:GetMaterial():Filter(Card.IsSetCard,nil,0xb29)
	local att=0
	local tc=g:GetFirst()
	while tc do
		att=bit.bor(att,tc:GetOriginalAttribute())
		tc=g:GetNext()
	end
	e:SetLabel(att)
end
function c19990034.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function c19990034.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c19990034.aclimit)
	e1:SetLabelObject(e:GetLabelObject())
	c:RegisterEffect(e1)
	local att=e:GetLabelObject():GetLabel()
	if bit.band(att,ATTRIBUTE_EARTH)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19990034,2))
	end
	if bit.band(att,ATTRIBUTE_WATER)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19990034,3))
	end
	if bit.band(att,ATTRIBUTE_FIRE)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19990034,4))
	end
	if bit.band(att,ATTRIBUTE_WIND)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19990034,5))
	end
	if bit.band(att,ATTRIBUTE_LIGHT)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19990034,6))
	end
	if bit.band(att,ATTRIBUTE_DARK)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19990034,7))
	end
	if bit.band(att,ATTRIBUTE_DIVINE)~=0 then
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19990034,8))
	end
end
function c19990034.aclimit(e,re,tp)
	local att=e:GetLabelObject():GetLabel()
	return re:IsActiveType(TYPE_MONSTER) and bit.band(att,re:GetHandler():GetOriginalAttribute())~=0
end
function c19990034.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE)
end
function c19990034.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function c19990034.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function c19990034.cfilter1(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousControler(tp) and c:IsSetCard(0xb29)
end
function c19990034.thcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19990034.cfilter1,1,nil,tp)
end
function c19990034.cfilter2(c,tp)
	return c:IsFaceup() and c:IsPreviousControler(tp) and c:IsSetCard(0xb29,0xb30)
end
function c19990034.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19990034.cfilter2,1,nil,tp)
end
function c19990034.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return g:GetCount()>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c19990034.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function c19990034.spsfilter(c,tp)
	return c:IsSetCard(0xb29) and Duel.GetMZoneCount(tp,c)>0
end
function c19990034.spscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,c19990034.spsfilter,4,REASON_COST,true,e,tp) end
	local g=Duel.SelectReleaseGroupEx(tp,c19990034.spsfilter,4,4,REASON_COST,true,e,tp)
	Duel.Release(g,REASON_COST)
end
function c19990034.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c19990034.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end