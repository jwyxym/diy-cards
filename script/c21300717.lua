--日冕晕龙
function c21300717.initial_effect(c)
	--spsummon self
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION) 
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE) 
	e1:SetCountLimit(1,21300717) 
	e1:SetTarget(c21300717.spstg)
	e1:SetOperation(c21300717.spsop)
	c:RegisterEffect(e1)
	--xyzlv
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_XYZ_LEVEL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c21300717.xyzlv)
	e2:SetLabel(8)
	c:RegisterEffect(e2)
	--overlay
	local e3=Effect.CreateEffect(c) 
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY) 
	e3:SetCountLimit(1,11300717)
	e3:SetTarget(c21300717.ovtg)
	e3:SetOperation(c21300717.ovop)
	c:RegisterEffect(e3)
end 
function c21300717.dgck(g,tp) 
	return Duel.GetMZoneCount(tp,g)>0  
end 
function c21300717.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,c) 
	if chk==0 then return g:CheckSubGroup(c21300717.dgck,2,2,g,tp) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,tp,LOCATION_HAND+LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end 
function c21300717.thfil(c) 
	return c:IsFaceup() and c:IsSetCard(0x680)
end 
function c21300717.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,c) 
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY) 
	if g:CheckSubGroup(c21300717.dgck,2,2,g,tp) then 
		local dg=g:SelectSubGroup(tp,c21300717.dgck,false,2,2,g,tp)
		if Duel.Destroy(dg,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(c21300717.thfil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(21300717,0)) then
			local sg=Duel.SelectMatchingCard(tp,c21300717.thfil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil) 
			Duel.SendtoHand(sg,tp,REASON_EFFECT)   
		end 
	end
end
function c21300717.xyzlv(e,c,rc)
	if rc:IsAttribute(ATTRIBUTE_FIRE) then
		return c:GetLevel()+0x10000*e:GetLabel()
	else
		return c:GetLevel()
	end
end
function c21300717.ovfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_XYZ)
end
function c21300717.ovtg(e,tp,eg,ep,ev,re,r,rp,chk) 
	if chk==0 then return Duel.IsExistingMatchingCard(c21300717.ovfilter,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsCanOverlay() end 
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function c21300717.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.SelectMatchingCard(tp,c21300717.ovfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc and c:IsRelateToEffect(e) and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(tc,c)
	end
end


