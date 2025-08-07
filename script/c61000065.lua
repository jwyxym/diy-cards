--观海 逐流
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
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
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp):Filter(aux.TRUE,c)
		Auxiliary.GCheckAdditional=Auxiliary.RitualCheckAdditional(c,1,"Greater")
		local bool=mg:CheckSubGroup(Auxiliary.RitualCheck,1,mg:GetCount(),tp,c,1,"Greater")
			or Duel.IsExistingMatchingCard(s.spcfilter,tp,0,LOCATION_MZONE,1,nil)
		Auxiliary.GCheckAdditional=nil
		local res=c:CheckUniqueOnField(tp) and not c:IsForbidden()
			and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		return bool or res
	end
end
function s.spcfilter(c)
	return c:IsFaceup() and c:IsReleasable() and c:IsCode(61000069)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rmg=Duel.GetRitualMaterial(tp):Filter(aux.TRUE,c)
	Auxiliary.GCheckAdditional=Auxiliary.RitualCheckAdditional(c,6,"Greater")
	local bool=(rmg:CheckSubGroup(Auxiliary.RitualCheck,1,rmg:GetCount(),tp,c,6,"Greater")
		or Duel.IsExistingMatchingCard(s.spcfilter,tp,0,LOCATION_MZONE,1,nil))
		and c:IsRelateToEffect(e)
	local mg=Duel.GetReleaseGroup(tp,true):Filter(Card.IsLevelAbove,nil,1)
	local res=c:CheckUniqueOnField(tp) and not c:IsForbidden()
			and c:IsRelateToEffect(e)
			and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	if not bool and not res then return end
	if bool and (not res or not Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local mat=Group.CreateGroup()
		if rmg:CheckSubGroup(Auxiliary.RitualCheck,1,rmg:GetCount(),tp,c,6,"Greater")
			and (not Duel.IsExistingMatchingCard(s.spcfilter,tp,0,LOCATION_MZONE,1,nil)
			or not Duel.SelectYesNo(tp,aux.Stringid(id,2))) then
			local rmg=Duel.GetRitualMaterial(tp):Filter(aux.TRUE,c)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			mat=rmg:SelectSubGroup(tp,Auxiliary.RitualCheck,false,1,rmg:GetCount(),tp,c,6,"Greater")
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
				and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
				local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
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
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local eqg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil,c)
		if #eqg>0 then
			Duel.HintSelection(eqg)
			Duel.Equip(tp,c,eqg:GetFirst())
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetLabelObject(eqg:GetFirst())
			e1:SetValue(s.eqlimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
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
function s.eqlimit2(e,c)
	return e:GetOwner()==c
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
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