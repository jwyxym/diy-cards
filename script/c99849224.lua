-- 鬼八仙·阴兵过境 (ID:99849224)
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,99849227)

	-- ①
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE+CATEGORY_DRAW+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end


function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,99849227)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end


function s.gy_count(tp)
	return Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,99849227)
end


function s.oppo_monster_filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end


function s.sumlimit(e,c)
	return not c:IsRace(RACE_ZOMBIE)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local from_grave = false
	local summoned = false

 
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,
			LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			from_grave = tc:IsLocation(LOCATION_GRAVE)
			summoned = Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		end
	end


	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.sumlimit)
	Duel.RegisterEffect(e1,tp)

  
	if from_grave and summoned then
		local ct = s.gy_count(tp)

		-- ●1张以上
		if ct>=1 then
			Duel.BreakEffect()
			Duel.Damage(0,800,REASON_EFFECT)
			Duel.Damage(1,800,REASON_EFFECT)
		end

		-- ●2张以上
		if ct>=2 and Duel.IsPlayerCanDraw(tp,1) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end

		-- ●3张
		if ct>=3 then
			Duel.BreakEffect()
			local g2=Duel.GetMatchingGroup(s.oppo_monster_filter,1-tp,LOCATION_MZONE,0,nil)
			for tc in aux.Next(g2) do
				local e_atk=Effect.CreateEffect(e:GetHandler())
				e_atk:SetType(EFFECT_TYPE_SINGLE)
				e_atk:SetCode(EFFECT_UPDATE_ATTACK)
				e_atk:SetValue(-800)
				e_atk:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e_atk)
				local e_def=e_atk:Clone()
				e_def:SetCode(EFFECT_UPDATE_DEFENSE)
				tc:RegisterEffect(e_def)
			end
		end
	end
end