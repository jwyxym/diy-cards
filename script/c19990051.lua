--
function c19990051.initial_effect(c)
	c:SetSPSummonOnce(19990051)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_PENDULUM),2,2)
	--att and race change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19990051,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c19990051.artg)
	e1:SetOperation(c19990051.arop)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetCountLimit(1)
	e2:SetDescription(aux.Stringid(19990051,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetCondition(c19990051.spscon)
	e2:SetTarget(c19990051.spstg)
	e2:SetOperation(c19990051.spsop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
function c19990051.artg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return ((RACE_ALL&~c:GetRace())~=0 or (ATTRIBUTE_ALL&~c:GetAttribute())~=0) end
	local race,att
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
	if ATTRIBUTE_ALL&~c:GetAttribute()==0 then
		race=Duel.AnnounceRace(tp,1,RACE_ALL&~c:GetRace())
	else
		race=Duel.AnnounceRace(tp,1,RACE_ALL)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	if RACE_ALL&~c:GetRace()==0 or race==c:GetRace() then
		att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~c:GetAttribute())
	else
		att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	end
	e:SetLabel(race,att)
end
function c19990051.arop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rac,att=e:GetLabel()
	if c:IsRelateToChain() and c:IsFaceup() then
		if not c:IsAttribute(att) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetValue(att)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			c:RegisterEffect(e1)
		end
		if not c:IsRace(rac) then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CHANGE_RACE)
			e2:SetValue(rac)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			c:RegisterEffect(e2)
		end
	end
end
function c19990051.spscon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c19990051.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c19990051.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
