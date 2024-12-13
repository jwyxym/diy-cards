--日冕灼耀龙
function c21300701.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),10,2)
	c:EnableReviveLimit()
	--destroy all
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)  
	e1:SetCountLimit(1,21300701)
	e1:SetCondition(function(e) 
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) end) 
	e1:SetTarget(c21300701.destg)
	e1:SetOperation(c21300701.desop)
	c:RegisterEffect(e1)
	--negate
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,11300701)
	e2:SetCondition(c21300701.discon)
	e2:SetTarget(c21300701.distg)
	e2:SetOperation(c21300701.disop)
	c:RegisterEffect(e2) 
	--dd 
	local e3=Effect.CreateEffect(c) 
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,31300701) 
	e3:SetTarget(c21300701.ddtg)
	e3:SetOperation(c21300701.ddop)
	c:RegisterEffect(e3)
end 
function c21300701.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	if chk==0 then return g:GetCount()>0 end 
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end 
function c21300701.spfil(c,e,tp) 
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0x680) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end  
function c21300701.sggck(g,e,tp) 
	if Duel.IsPlayerAffectedByEffect(tp,59822133) and g:GetCount()>1 then return false end 
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>=g:GetCount() and aux.dncheck(g)
end  
function c21300701.desop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD) 
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		local sg=Duel.GetMatchingGroup(c21300701.spfil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp) 
		if sg:CheckSubGroup(c21300701.sggck,1,2,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(21300701,0)) then 
			Duel.BreakEffect() 
			local ssg=sg:SelectSubGroup(tp,c21300701.sggck,false,1,2,e,tp) 
			Duel.SpecialSummon(ssg,0,tp,tp,false,false,POS_FACEUP) 
		end 
	end
end
function c21300701.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and re:IsActiveType(TYPE_MONSTER) and bit.band(re:GetActivateLocation(),LOCATION_HAND+LOCATION_GRAVE)~=0 
end
function c21300701.distg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local b1=Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT)
	local b2=Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,0x680)
	if chk==0 then return b1 or b2 end 
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c21300701.disop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	local b1=Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT)
	local b2=Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,0x680)
	if b1 or b2 then  
		local xtable={} 
		if b1 then table.insert(xtable,aux.Stringid(21300701,1)) end 
		if b2 then table.insert(xtable,aux.Stringid(21300701,2)) end 
		local op=Duel.SelectOption(tp,table.unpack(xtable))+1 
		local x=0 
		if xtable[op]==aux.Stringid(21300701,1) and Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) then 
			if Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)~=0 then 
				x=1 
			end 
		end 
		if xtable[op]==aux.Stringid(21300701,2) and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,0x680) then 
			local dg=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,0x680) 
			if Duel.Destroy(dg,REASON_EFFECT)~=0 then 
				x=1 
			end 
		end  
		if x~=0 and Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			Duel.Destroy(eg,REASON_EFFECT)
		end 
	end 
end
function c21300701.ddtg(e,tp,eg,ep,ev,re,r,rp,chk) 
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,0x680) end 
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_DECK) 
end
function c21300701.ddop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	if Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,0x680) then 
		local dg=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,0x680) 
		Duel.Destroy(dg,REASON_EFFECT) 
	end 
end 

