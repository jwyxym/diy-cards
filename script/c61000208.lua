--古之凶祸 尸骸之王
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,61000203)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o*10000)
	e2:SetLabelObject(e0)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.cfilter(c,e,tp,ec)
	local mg=Duel.GetRitualMaterial(tp)
	mg:Sub(Group.FromCards(c))
	return (c==ec or c:IsRace(RACE_ZOMBIE) and c:IsLevelAbove(8)) and c:IsLocation(LOCATION_HAND)
		and Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,s.filter,e,tp,mg,dg,Card.GetLevel,"Greater")
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,s.cfilter,1,REASON_COST,true,nil,e,tp,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroupEx(tp,s.cfilter,1,1,REASON_COST,true,nil,e,tp,c)
	Duel.Release(g,REASON_COST)
end
function s.dfilter(c)
	return c:IsSetCard(0x106) and c:IsLevelAbove(1) and c:IsAbleToGrave()
end
function s.tgfilter(c,e,tp)
	local mg=Duel.GetRitualMaterial(tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsAllTypes(TYPE_RITUAL+TYPE_MONSTER) and c:IsAbleToGrave() and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_TOKEN_MONSTER,c:GetAttack(),c:GetDefense(),c:GetLevel(),RACE_ZOMBIE,c:GetAttribute())
		and Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,s.filter2(c),e,tp,mg,dg,Card.GetLevel,"Greater")
end
function s.filter(c,e,tp)
	if not c:IsRace(RACE_ZOMBIE) then return false end
	if c:IsLocation(LOCATION_DECK) then
		return c:IsAbleToGrave() and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_TOKEN_MONSTER,c:GetAttack(),c:GetDefense(),c:GetLevel(),RACE_ZOMBIE,c:GetAttribute())
	else
		return true
	end
end
function s.filter2(ec)
	return function (c,e,tp)
		if not c:IsRace(RACE_ZOMBIE) then return false end
		if c:IsLocation(LOCATION_DECK) and c~=ec then
			return false
		else
			return true
		end
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp)
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,s.filter,e,tp,mg,dg,Card.GetLevel,"Greater")
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.thfilter(c)
	return aux.IsCodeListed(c,61000203) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		::cancel::
		local m=Duel.GetRitualMaterial(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(aux.RitualUltimateFilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,s.filter,e,tp,m,dg,Card.GetLevel,"Greater")
		local tc=tg:GetFirst()
		if tc then
			local mg=m:Filter(Card.IsCanBeRitualMaterial,tc,tc)
			if tc.mat_filter then
				mg=mg:Filter(tc.mat_filter,tc,tp)
			else
				mg:RemoveCard(tc)
			end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
			local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
			aux.GCheckAdditional=nil
			if not mat then
				aux.RCheckAdditional=nil
				aux.RGCheckAdditional=nil
				goto cancel
			end
			tc:SetMaterial(mat)
			local dmat=mat:Filter(Card.IsLocation,nil,LOCATION_DECK)
			if dmat:GetCount()>0 then
				mat:Sub(dmat)
				Duel.SendtoGrave(dmat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
			end
			Duel.ReleaseRitualMaterial(mat)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
			tc:CompleteProcedure()
			if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
				if g:GetCount()>0 then
					Duel.BreakEffect()
					Duel.SendtoHand(g,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,g)
				end
			end
		end
	end
end
function s.cfilter2(c,tp,se,re)
	return (c:IsReason(REASON_COST) and re:IsActivated() and re:GetHandler()==c
		or c:IsReason(REASON_BATTLE) or c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp)
		and c:IsCode(61000203)
		and (se==nil or c:GetReasonEffect()~=se) and c:IsControler(tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter2,1,c,tp,se,re)
end
function s.lkfilter(c)
	return c:IsLinkSummonable(nil) and c:IsRace(RACE_ZOMBIE)
end
function s.crtg(e,c)
	return c:GetOwner()~=e:GetOwner()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetValue(RACE_ZOMBIE)
		e1:SetTarget(s.crtg)
		Duel.RegisterEffect(e1,tp)
		local res=Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_EXTRA,0,1,nil)
		e1:Reset()
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(RACE_ZOMBIE)
	e1:SetTarget(s.crtg)
	Duel.RegisterEffect(e1,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.lkfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SPSUMMON_COST)
		e2:SetLabelObject(e1)
		e2:SetOperation(s.spcop)
		tc:RegisterEffect(e2)
		Duel.LinkSummon(tp,tc,nil)
	end
end
function s.spcop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():Reset()
	if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
	e:Reset()
end
function s.thfilter2(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToHand()
end