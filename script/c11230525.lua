--DS 冰晶冻结
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

function s.thfilter(c)
	return c:IsCode(11230500) and c:IsAbleToHand()
end

function s.plfilter(c)
	return c:IsSetCard(0xb74) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS) and c:IsSSetable()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b1alt=Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0xb74)
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	if chk==0 then return b1 or b1alt end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local bth=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local bpl=Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0xb74)
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	local sub=0
	if bth and bpl then
		sub=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif bpl then
		sub=1
	end
	if sub==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	end
end

function s.rtfilter(c)
	return c:IsAbleToHand()
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rtfilter,tp,0,LOCATION_ONFIELD,1,nil) end
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.rtfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		local og=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_MZONE,nil,TYPE_XYZ)
		if og:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) and Duel.RemoveOverlayCard(tp,0,1,1,4,REASON_EFFECT)~=0 then
		end
		local xyz=Duel.GetMatchingGroup(s.rank5filter,tp,LOCATION_MZONE,0,nil)
		if xyz:GetCount()>0 and Duel.IsExistingMatchingCard(s.afilter,tp,LOCATION_EXTRA,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local sg=xyz:Select(tp,1,1,nil)
			local xc=sg:GetFirst()
			local sc=Duel.GetMatchingGroup(s.afilter,tp,LOCATION_EXTRA,0,nil):GetFirst()
			if xc and sc and Duel.GetLocationCountFromEx(tp,tp,xc,sc)>0 then
				local mg=xc:GetOverlayGroup()
				if mg:GetCount()~=0 then
					Duel.Overlay(sc,mg)
				end
				sc:SetMaterial(Group.FromCards(xc))
				Duel.Overlay(sc,Group.FromCards(xc))
				Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
				sc:CompleteProcedure()
			end
		end
	end
end

function s.rank5filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb74) and c:IsType(TYPE_XYZ) and c:IsRank(5)
end

function s.afilter(c)
	return c:IsCode(11230515)
end