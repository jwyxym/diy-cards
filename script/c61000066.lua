--观海 迁溯
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_DECKDES+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetValue(61000069)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_RELEASE)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp):Filter(aux.TRUE,c)
		Auxiliary.GCheckAdditional=Auxiliary.RitualCheckAdditional(c,4,"Greater")
		local bool=mg:CheckSubGroup(Auxiliary.RitualCheck,1,mg:GetCount(),tp,c,4,"Greater")
			or Duel.IsExistingMatchingCard(s.spcfilter,tp,0,LOCATION_MZONE,1,nil)
		Auxiliary.GCheckAdditional=nil
		local mg=Duel.GetReleaseGroup(tp,true):Filter(Card.IsLevelAbove,nil,1)
		local res=(Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			and mg:CheckWithSumGreater(Card.GetLevel,4)
			or Duel.IsExistingMatchingCard(s.spcfilter2,tp,0,LOCATION_MZONE,1,nil,tp))
			and Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp)
			and c:CheckUniqueOnField(tp) and not c:IsForbidden()
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		return bool or res
	end
end
function s.spcfilter(c)
	return c:IsFaceup() and c:IsReleasable() and c:IsCode(61000069)
end
function s.spcfilter2(c,tp)
	return c:IsFaceup() and c:IsReleasable() and c:IsCode(61000069)
		and Duel.GetMZoneCount(tp,c)>0
end
function s.fselect(g)
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(Card.GetLevel,4)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=Duel.GetRitualMaterial(tp):Filter(aux.TRUE,c)
	Auxiliary.GCheckAdditional=Auxiliary.RitualCheckAdditional(c,4,"Greater")
	local bool=(mg:CheckSubGroup(Auxiliary.RitualCheck,1,mg:GetCount(),tp,c,4,"Greater")
		or Duel.IsExistingMatchingCard(s.spcfilter,tp,0,LOCATION_MZONE,1,nil))
		and c:IsRelateToEffect(e)
	local mg2=Duel.GetReleaseGroup(tp,true):Filter(Card.IsLevelAbove,nil,1)
	local res=(Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			and mg2:CheckWithSumGreater(Card.GetLevel,4)
			or Duel.IsExistingMatchingCard(s.spcfilter2,tp,0,LOCATION_MZONE,1,nil,tp))
			and c:IsRelateToEffect(e)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp)
			and c:CheckUniqueOnField(tp) and not c:IsForbidden()
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	if not bool and not res then return end
	if bool and (not res or not Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local mat=Group.CreateGroup()
		if mg:CheckSubGroup(Auxiliary.RitualCheck,1,1,tp,c,4,"Greater")
			and (not Duel.IsExistingMatchingCard(s.spcfilter,tp,0,LOCATION_MZONE,1,nil)
			or not Duel.SelectYesNo(tp,aux.Stringid(id,2))) then
			local mg=Duel.GetRitualMaterial(tp)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			mat=mg:SelectSubGroup(tp,Auxiliary.RitualCheck,false,1,mg:GetCount(),tp,c,1,"Greater")
			Auxiliary.GCheckAdditional=nil
		else
			mat=Duel.SelectMatchingCard(tp,s.spcfilter,tp,0,LOCATION_MZONE,1,1,nil)
		end
		if mat and mat:GetCount()>0 then
			c:SetMaterial(mat)
			Duel.ReleaseRitualMaterial(mat)
			Duel.SpecialSummon(c,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
			c:CompleteProcedure()
			if Duel.GetLocationCount(tp,LOCATION_SZONE)>0
				and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
				and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
				local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,TYPE_MONSTER)
				local tc=g:GetFirst()
				if tc then
					if not Duel.Equip(tp,tc,c) then return end
					local e1=Effect.CreateEffect(c)
					e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_EQUIP_LIMIT)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					e1:SetValue(s.eqlimit2)
					tc:RegisterEffect(e1)
				end
			end
		end
	else
		local mg3=Group.CreateGroup()
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			and mg2:CheckWithSumGreater(Card.GetLevel,4)
			and not Duel.IsExistingMatchingCard(s.spcfilter2,tp,0,LOCATION_MZONE,1,nil,tp)
			or not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			mg3=mg2:SelectSubGroup(tp,s.fselect,false,1,mg2:GetCount())
		else
			mg3=Duel.SelectMatchingCard(tp,s.spcfilter,tp,0,LOCATION_MZONE,1,1,nil)
		end
		Duel.Release(mg3,REASON_EFFECT)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
		local ttc=g:GetFirst()
		if ttc then
			Duel.SpecialSummon(ttc,0,tp,1-tp,false,false,POS_FACEUP)
			if not Duel.Equip(tp,c,ttc) then return end
			local e1=Effect.CreateEffect(ttc)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit2)
			c:RegisterEffect(e1)
		end
	end
	Auxiliary.GCheckAdditional=nil
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
function s.eqlimit2(e,c)
	return e:GetOwner()==c
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
		and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
function s.thfilter(c)
	return c:IsSetCard(0xc7c0) and c:IsType(TYPE_RITUAL)
		and c:IsType(TYPE_MONSTER)
		and c:IsAbleToHand()
		and not c:IsLevel(6)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end