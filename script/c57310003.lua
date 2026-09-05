--乌涅
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,57310005)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+id)
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
end
function s.filter_sefi(c,e,tp)
	return c:IsCode(57310001)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) or (c:IsLocation(LOCATION_GRAVE+LOCATION_DECK) and c:IsAbleToHand())
end
function s.derivative_filter(c)
	return c:IsType(TYPE_TOKEN) and c:IsCode(57310005)
end

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.filter_sefi,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return b1 or b2
	end
	local op=0
	if b1 or b2 then
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},
			{b2,aux.Stringid(id,3),2})
	end
	if op==1 then
		e:SetLabel(1)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
	elseif op==2 then
		e:SetLabel(2)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	end
end

function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	if opt==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.filter_sefi,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g==0 then return end
		local tc=g:GetFirst()
		if tc:IsLocation(LOCATION_DECK+LOCATION_GRAVE) then
			local b1=tc:IsAbleToHand()
			local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			local op=aux.SelectFromOptions(tp,{b1,1190},{b2,1152})
			if op==1 then
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
			end
			if op==2 then
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
			else
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetTarget(s.splimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
	elseif opt==2 then
		local token=Duel.CreateToken(tp,57310005)
		if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local g=Duel.GetMatchingGroup(s.filter_atk2000,tp,0,LOCATION_MZONE,nil)
			if #g>0 and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
				and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
				if Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD,nil)~=0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local dg=Duel.SelectMatchingCard(tp,s.filter_atk2000,tp,0,LOCATION_MZONE,1,1,nil)
				if #dg>0 then
					Duel.Destroy(dg,REASON_EFFECT)
				end
				end
			end
		end
	end
end
function s.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
function s.filter_atk2000(c)
	return c:IsFaceup() and c:GetAttack()<=2000
end

function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=eg:Filter(s.leave_filter,nil)
	return #tg>0 and c:IsLocation(LOCATION_GRAVE)
end
function s.leave_filter(c)
	return aux.IsCodeOrListed(c,57310005) and c:IsPreviousLocation(LOCATION_MZONE)
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,tp,LOCATION_GRAVE)
end

function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end
