-- 爱神的花之矢
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,72600560) 
	-- 特殊召唤效果
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost) 
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 作为超量素材
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_XYZ_LEVEL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.xyzlv)
	e2:SetLabel(3)
	c:RegisterEffect(e2)
	-- 墓地中作为超量素材
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+2)
	e3:SetLabelObject(e0)
	e3:SetCondition(s.matcon)
	e3:SetTarget(s.mattg)
	e3:SetOperation(s.matop)
	c:RegisterEffect(e3)
	aux.RegisterMergedDelayedEvent(c,id,EVENT_SPSUMMON_SUCCESS)
end
function s.filter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsLevel(3,4) and not c:IsPublic()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(72600572,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,c)
	if #g==0 then return end
	g:AddCard(c)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetRange(LOCATION_MZONE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		Duel.SpecialSummonComplete()
	end
end
function s.splimit(e,c)
	return not (c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsType(TYPE_XYZ)) and c:IsLocation(LOCATION_EXTRA)
end
function s.xyzlv(e,c,rc)
	if rc:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) then
		return c:GetLevel()+0x10000*e:GetLabel()
	else
		return c:GetLevel()
	end
end
function s.cfilter(c,e,se)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsCanBeEffectTarget(e) and aux.IsCodeListed(c,72600560) and (se==nil or c:GetReasonEffect()~=se)
end
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,e,se)
end
function s.tgfilter(c,eg,tp)
	return eg:IsContains(c) and c:IsFaceup() and c:IsType(TYPE_XYZ) and aux.IsCodeListed(c,72600560) and c:IsSummonPlayer(tp)
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,eg,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,eg,tp)
		and e:GetHandler():IsCanOverlay() end
	if eg:GetCount()==1 then
		Duel.SetTargetCard(eg)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,eg,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
