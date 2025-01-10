--至高圣龙骑士
function c19000036.initial_effect(c)
	--synchro summon
	c:EnableReviveLimit()
	aux.AddSynchroMixProcedure(c,c19000036.matfilter,nil,nil,aux.NonTuner(nil),1,99)
	--
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_RACE)
	e0:SetRange(LOCATION_EXTRA+LOCATION_GRAVE)
	e0:SetValue(RACE_DRAGON)
	c:RegisterEffect(e0)
	--special summon1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19000036,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,19000036)
	e1:SetCondition(c19000036.spcon)
	e1:SetTarget(c19000036.sptg)
	e1:SetOperation(c19000036.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c19000036.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19000036,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,19000036+100)
	e3:SetCondition(c19000036.spscon1)
	e3:SetOperation(c19000036.tnop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c19000036.spscon2)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	c:RegisterEffect(e4)
end
function c19000036.matfilter(c,syncard)
	return c:IsTuner(syncard) or c:IsAttribute(ATTRIBUTE_LIGHT)
end
function c19000036.mfilter(c)
	return not c:IsType(TYPE_SYNCHRO)
end
function c19000036.valcheck(e,c)
	local g=c:GetMaterial()
	if g:GetCount()>0 and not g:IsExists(c19000036.mfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function c19000036.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()==1
end
function c19000036.spfilter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevelBelow(5) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function c19000036.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		and Duel.IsExistingMatchingCard(c19000036.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c19000036.spop(e,tp,eg,ep,ev,re,r,rp)
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c19000036.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)~=0 then
		tc:CompleteProcedure()
	end
end
function c19000036.spscon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re and re:GetHandler():IsType(TYPE_SPELL) and c:IsReason(REASON_EFFECT)
end
function c19000036.spscon2(e,tp,eg,ep,ev,re,r,rp)
	local typ,race=e:GetHandler():GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_RACE)
	return typ&TYPE_MONSTER~=0 and race&RACE_DRAGON~=0
end
function c19000036.tnop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c19000036.tnval)
	e1:SetValue(TYPE_SYNCHRO)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTarget(c19000036.splimit)
	Duel.RegisterEffect(e2,tp)
end
function c19000036.tnval(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsFaceup()
end
function c19000036.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end