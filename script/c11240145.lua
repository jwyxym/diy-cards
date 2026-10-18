-- DS 海后安菲兽&东御手洗清司郎
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SSET+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(aux.bfgcost)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,5))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.xmatcon)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)
end
function s.cfilter(c)
	return c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_WATER)
end
function s.lvfilter(c)
	return c:IsFaceup() and c:GetLevel()>0 and c:GetLevel()~=6
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=true
	local b2=Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
	if c:IsRelateToChain(e) then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and (b1 or b2) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			local op=0
			if (c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:GetLevel()>1) and b2 then op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
			elseif (c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:GetLevel()>1) then op=Duel.SelectOption(tp,aux.Stringid(id,1))
			elseif b2 then op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
			else return end
			Duel.BreakEffect()
			if op==0 then
				Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
				local lv=Duel.AnnounceLevel(tp,1,4)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_LEVEL)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
				e1:SetValue(-lv)
				c:RegisterEffect(e1)
			else
				Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
				local g=Duel.SelectMatchingCard(tp,s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,c)
				local tc=g:GetFirst()
				Duel.HintSelection(g)
				while tc do
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_CHANGE_LEVEL)
					e1:SetValue(6)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e1)
					tc=g:GetNext()
				end
			end
		end
	end
end
function s.cfilter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.thfilter(c)
	if not (c:IsSetCard(0xb74) and c:IsType(TYPE_SPELL)) then return false end
	return c:IsAbleToHand() or c:IsSSetable()
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		if tc:IsAbleToHand() and (not tc:IsSSetable() or Duel.SelectOption(tp,1190,1153)==0) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SSet(tp,tc)
		end
	end
end
function s.xmatcon(e)
	return e:GetHandler():GetAttribute()==ATTRIBUTE_WATER
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetOverlayCount()>0 and c:CheckRemoveOverlayCard(tp,c:GetOverlayCount(),REASON_COST) end
	Duel.SendtoGrave(c:GetOverlayGroup(),REASON_COST)
end
function s.spfilter(c,e,tp,mc,rank)
	return c:IsRank(rank) and c:IsSetCard(0xb74) and mc:IsCanBeXyzMaterial(c) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=Group.FromCards(c)
	if c:IsRelateToChain(e) and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c,c:GetRank())
		local tc=g:GetFirst()
		if tc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()>0 then
				Duel.Overlay(tc,mg)
			end
			tc:SetMaterial(Group.FromCards(c))
			Duel.Overlay(tc,Group.FromCards(c))
			if Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
				tc:CompleteProcedure()
			end
		end
	end
end