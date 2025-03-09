--邪魔兽核-邪之眼
function c19000053.initial_effect(c)
	c:EnableReviveLimit()
	--spsummon& xyz
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(19000053,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCountLimit(1,19000053)
	e0:SetCondition(c19000053.spcon)
	e0:SetTarget(c19000053.sptg)
	e0:SetOperation(c19000053.spop)
	c:RegisterEffect(e0)
	--spsummon limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c19000053.sumlimit)
	c:RegisterEffect(e1)
	--get effect extra material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	e2:SetDescription(aux.Stringid(19000053,2))
	e2:SetCode(EFFECT_OVERLAY_RITUAL_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c19000053.condition)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
function c19000053.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
function c19000053.filter(c,e,tp)
	return (c:IsRank(9) or c:IsLevel(9)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c19000053.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c19000053.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function c19000053.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c19000053.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
	Duel.SpecialSummonComplete()
	if Duel.SelectYesNo(tp,aux.Stringid(19000053,1)) then
	   local g=Duel.SelectMatchingCard(tp,c19000053.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	   Duel.BreakEffect()
	   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	   if g:GetCount()>0 then
		  Duel.XyzSummon(tp,g:GetFirst(),nil)
	   end
	end
end
function c19000053.xyzfilter(c)
	return c:IsRank(9) and c:IsXyzSummonable(nil)
end
function c19000053.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_XYZ)
end
function c19000053.condition(e)
	return e:GetHandler():GetOriginalRank()==9
end