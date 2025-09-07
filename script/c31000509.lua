--希望姬导士-神光希望姬
function c31000509.initial_effect(c)
	c:EnableReviveLimit()
	--material
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,0x30),aux.NonTuner(nil),1)
	--to hand or grave
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,31000509)
	e1:SetCondition(c31000509.thcon)
	e1:SetTarget(c31000509.thtg)
	e1:SetOperation(c31000509.thop)
	c:RegisterEffect(e1)
	--to field
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,31000509+1)
	e2:SetTarget(c31000509.target)
	e2:SetOperation(c31000509.operation)
	c:RegisterEffect(e2)
	--to grave
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c31000509.regop)
	c:RegisterEffect(e3)
	--to hand/spsummon
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_LEAVE_GRAVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,31000509+2)
	e4:SetCondition(c31000509.spcon)
	e4:SetTarget(c31000509.sptg)
	e4:SetOperation(c31000509.spop)
	c:RegisterEffect(e4)
end
function c31000509.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function c31000509.thfilter(c)
	return c:IsSetCard(0x314) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function c31000509.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31000509.thfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c31000509.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,c31000509.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
function c31000509.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and Duel.GetMZoneCount(tp,c)>1
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31000510,0,TYPES_TOKEN_MONSTER+TYPE_TUNER,500,1000,4,RACE_WARRIOR,ATTRIBUTE_LIGHT)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31000511,0,TYPES_TOKEN_MONSTER,1000,500,4,RACE_WARRIOR,ATTRIBUTE_LIGHT)
		end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
function c31000509.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>1
			and Duel.IsPlayerCanSpecialSummonMonster(tp,31000510,0,TYPES_TOKEN_MONSTER+TYPE_TUNER,500,1000,4,RACE_WARRIOR,ATTRIBUTE_LIGHT)
			and Duel.IsPlayerCanSpecialSummonMonster(tp,31000511,0,TYPES_TOKEN_MONSTER,1000,500,4,RACE_WARRIOR,ATTRIBUTE_LIGHT) then
			local token1=Duel.CreateToken(tp,31000510)
			Duel.SpecialSummonStep(token1,0,tp,tp,false,false,POS_FACEUP)
			local token2=Duel.CreateToken(tp,31000511)
			Duel.SpecialSummonStep(token2,0,tp,tp,false,false,POS_FACEUP)
			if Duel.SpecialSummonComplete()>0 then
				local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_HAND,0,nil)
				local sg=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
				if #g>0 and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(31000509,4)) then
					Duel.BreakEffect()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
					local g1=g:Select(tp,1,1,nil)
					if Duel.SendtoDeck(g1,nil,2,0x40)>0 then
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
						local sg1=sg:Select(tp,1,1,nil)
						Duel.SynchroSummon(tp,sg1:GetFirst(),nil)
					end
				end
			end
		end
	end
end
function c31000509.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(31000509,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function c31000509.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(31000509)>0 and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousLocation(LOCATION_SZONE)
end
function c31000509.spfilter(c,e,tp)
	return c:IsSetCard(0x314) and c:IsType(0x1)
		and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		or (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and not c:IsForbidden()))
end
function c31000509.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31000509.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
end
function c31000509.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c31000509.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local res=0
	if tc then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and not c:IsForbidden()
			and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or Duel.GetLocationCount(tp,0x4)<=0
				or Duel.SelectOption(tp,1152,aux.Stringid(31000509,0))==1) then
			if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
				local e1=Effect.CreateEffect(c)
				e1:SetCode(EFFECT_CHANGE_TYPE)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
				e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
				tc:RegisterEffect(e1)
				res=1
			end
		else
			res=Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if res>0 then
		local g=Duel.GetMatchingGroup(c31000509.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(31000509,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local tc=g:Select(tp,1,1,nil):GetFirst()
			local down=tc:IsLevelAbove(2)
			local op=aux.SelectFromOptions(tp,{true,aux.Stringid(31000509,2)},{down,aux.Stringid(31000509,3)})
			local slv=tc:GetLevel()
			local lv=0
			if op==1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
				lv=Duel.AnnounceLevel(tp,1,4)
			elseif op==2 then
				Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
				lv=Duel.AnnounceLevel(tp,1,math.min(slv-1,4))*-1
			end
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			tc:RegisterEffect(e1)
		end
	end
end
function c31000509.lvfilter(c)
	return c:IsLevelAbove(1) and c:IsFaceup()
end