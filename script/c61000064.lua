--观海 暗流
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetValue(61000069)
	c:RegisterEffect(e2)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp)
		Auxiliary.GCheckAdditional=Auxiliary.RitualCheckAdditional(c,2,"Greater")
		local bool=mg:CheckSubGroup(Auxiliary.RitualCheck,1,mg:GetCount(),tp,c,2,"Greater")
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
	local mg=Duel.GetRitualMaterial(tp)
	Auxiliary.GCheckAdditional=Auxiliary.RitualCheckAdditional(c,2,"Greater")
	local bool=(mg:CheckSubGroup(Auxiliary.RitualCheck,1,mg:GetCount(),tp,c,2,"Greater")
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
		if mg:CheckSubGroup(Auxiliary.RitualCheck,1,mg:GetCount(),tp,c,2,"Greater")
			and (not Duel.IsExistingMatchingCard(s.spcfilter,tp,0,LOCATION_MZONE,1,nil)
			or not Duel.SelectYesNo(tp,aux.Stringid(id,2))) then
			local mg=Duel.GetRitualMaterial(tp)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			mat=mg:SelectSubGroup(tp,Auxiliary.RitualCheck,true,1,mg:GetCount(),tp,c,2,"Greater")
			Auxiliary.GCheckAdditional=nil
		else
			mat=Duel.SelectMatchingCard(tp,s.spcfilter,tp,0,LOCATION_MZONE,1,1,nil)
		end
		if mat and mat:GetCount()>0 then
			c:SetMaterial(mat)
			Duel.ReleaseRitualMaterial(mat)
			Duel.SpecialSummon(c,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
			c:CompleteProcedure()
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
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end