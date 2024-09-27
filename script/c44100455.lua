--诺艾尔 骑士风度
function c44100455.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44100455,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,44100455)
	e1:SetCost(c44100455.tgcost)
	e1:SetTarget(c44100455.tgtg)
	e1:SetOperation(c44100455.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--set
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44100455,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,44100455)
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(c44100455.setcon)
	e3:SetTarget(c44100455.settg)
	e3:SetOperation(c44100455.setop)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(44100455,ACTIVITY_SPSUMMON,c44100455.counterfilter)
end
function c44100455.counterfilter(c)
	return c:IsSetCard(0x44a)
end
function c44100455.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(44100455,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c44100455.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c44100455.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x44a)
end
function c44100455.tgfilter(c)
	return c:IsSetCard(0x44a) and not c:IsCode(44100455) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function c44100455.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c44100455.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c44100455.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c44100455.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function c44100455.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x44a) and c:IsType(TYPE_MONSTER)
end
function c44100455.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c44100455.cfilter,tp,LOCATION_MZONE,0,3,nil)
end
function c44100455.setfilter(c)
	return c:IsSetCard(0x44a) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function c44100455.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(c44100455.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c44100455.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,c44100455.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end
