--RAS·佐藤益木
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetTarget(s.seletg)
	e2:SetOperation(s.seleop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCost(s.cost)
	e4:SetCountLimit(1,id+id+id)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.lktg)
	e4:SetOperation(s.lkop)
	c:RegisterEffect(e4)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
function s.counterfilter(c)
	return c:IsSetCard(0xf09)
end
function s.sfilter(c)
	local b1=c:IsCode(600501)
	local b2=c:GetMutualLinkedGroupCount()>0
	return c:IsFaceup() and (b1 or b2)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0xf09)
end
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0xf09) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thfilter(c)
	return c:IsLevel(5) and c:IsSetCard(0xf09) and c:IsAbleToHand()
end
function s.spfilter2(c,e,tp)
	return c:IsLevelBelow(2) and c:IsSetCard(0xf09) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.seletg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) and Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
end
function s.seleop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	local op=aux.SelectFromOptions(tp,{b1,1190},{b2,1118})
	if op==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0	and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0	and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,0,1,nil,e,tp) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
function s.matfilter(c)
	return c:IsFaceup()
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLinkState()
end
function s.lkfilter(c)
	return c:IsLinkSummonable(nil) and c:IsSetCard(0xf09)
end
function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil)
		return Duel.IsExistingMatchingCard(s.lcfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
function s.goal_check(g,tp,lc,e)
	if Duel.GetLocationCountFromEx(tp,tp,g,lc) <= 0 then return false end
	local target_link = lc:GetLink()
	local mask=1
	for tc in aux.Next(g) do
		local next_mask = 0
		local shift1 = bit.lshift(mask, 1)
		next_mask = bit.bor(next_mask, shift1)
		if tc==e:GetHandler() then
			local shift2=bit.lshift(mask, 2)
			next_mask=bit.bor(next_mask,shift2)
		elseif tc:IsType(TYPE_LINK) and tc:GetLink() > 1 then
			local shiftL=bit.lshift(mask, tc:GetLink())
			next_mask=bit.bor(next_mask,shiftL)
		end
		mask=next_mask
	end
	return bit.band(mask, bit.lshift(1, target_link))~=0
end
function s.lcfilter(c,e,tp,mg)
	if not c:IsType(TYPE_LINK) and c:IsSetCard(0xf09) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) then return false end
	return mg:CheckSubGroup(s.goal_check,2,c:GetLink(),tp,c,e)
end
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.lcfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
	local lc=g:GetFirst()
	if lc then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local mat_g=mg:SelectSubGroup(tp,s.goal_check,false,1,lc:GetLink(),tp,lc,e)
		if mat_g and #mat_g>0 then
			lc:SetMaterial(mat_g)
			if Duel.SendtoGrave(mat_g,REASON_EFFECT+REASON_MATERIAL+REASON_LINK)>0 then
				Duel.BreakEffect()
				if Duel.SpecialSummon(lc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)>0 then
					lc:CompleteProcedure()
				end
			end
		end
	end
end