local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddSetNameMonsterList(c,0x742)
	
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)

	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DICE+CATEGORY_SSET+CATEGORY_SPECIAL_SUMMON+CATEGORY_CONTROL+CATEGORY_DAMAGE+CATEGORY_DESTROY+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.dicecon1)
	e2:SetTarget(s.dicetg)
	e2:SetOperation(s.diceop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DICE+CATEGORY_SSET+CATEGORY_SPECIAL_SUMMON+CATEGORY_CONTROL+CATEGORY_DAMAGE+CATEGORY_DESTROY+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.ritualcon)
	e3:SetTarget(s.dicetg)
	e3:SetOperation(s.diceop)
	c:RegisterEffect(e3)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,1)
	e4:SetValue(s.aclimit)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_SSET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetOperation(s.aclimset)
	c:RegisterEffect(e5)
end
function s.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.thfilter(c)
	return c:IsCode(74400908,74400928) and c:IsAbleToHand()
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
function s.dicecon1(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
function s.ritualcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.setfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable() and (c:IsSetCard(0x742) or aux.IsSetNameMonsterListed(c,0x742))
end
function s.dicetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.diceop(e,tp,eg,ep,ev,re,r,rp)
	local dc=Duel.TossDice(tp,1)
	if dc==1 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
			local tc=g:GetFirst()
			if tc and Duel.SSet(tp,tc)~=0 then
				local te=Effect.CreateEffect(e:GetHandler())
				te:SetDescription(aux.Stringid(id,2))
				te:SetType(EFFECT_TYPE_SINGLE)
				te:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				te:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				te:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(te)
				local ee=Effect.CreateEffect(e:GetHandler())
				ee:SetType(EFFECT_TYPE_SINGLE)
				ee:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
				ee:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(ee)
			end
		end
	elseif dc==2 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
			local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsType),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,TYPE_MONSTER)
			local og=Duel.SelectMatchingCard(1-tp,aux.NecroValleyFilter(Card.IsType),1-tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,TYPE_MONSTER)
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			Duel.SpecialSummon(og,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	elseif dc==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local g=Duel.SelectMatchingCard(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			Duel.GetControl(g:GetFirst(),tp)
		end
	elseif dc==4 then
		local n=Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)
		if n>0 then
			Duel.Damage(tp,n*200,REASON_EFFECT)
			Duel.Damage(1-tp,n*200,REASON_EFFECT)
		end
	elseif dc==5 then
		local g=Duel.GetMatchingGroup(s.otherfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetHandler())
		if g:GetCount()>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif dc==6 then
		Duel.SetLP(tp,math.ceil(Duel.GetLP(tp)/2))
	end
end
function s.otherfilter(c,selfc)
	return c~=selfc and c:IsType(TYPE_MONSTER)
end
function s.aclimit(e,re,tp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return false end
	local c=re:GetHandler()
	return not c:IsLocation(LOCATION_SZONE) or c:GetFlagEffect(id)>0
end
function s.aclimset(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		local flag=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
		if tc:IsControler(tp) then
			flag=flag+RESET_SELF_TURN
		else
			flag=flag+RESET_OPPO_TURN
		end
		tc:RegisterFlagEffect(id,flag,0,1)
		tc=eg:GetNext()
	end
end