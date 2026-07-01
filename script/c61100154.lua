--三恶妖·邪灵龙
function c61100154.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61100154,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,61100154)
	e1:SetCondition(c61100154.spcon)
	e1:SetTarget(c61100154.sptg)
	e1:SetOperation(c61100154.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c61100154.splimit)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(61100154,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,61100154)
	e3:SetCost(c61100154.e3cost)
	e3:SetTarget(c61100154.e3tg)
	e3:SetOperation(c61100154.e3op)
	c:RegisterEffect(e3)
	if not c61100154.global_check then
		c61100154.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(c61100154.checkop)
		Duel.RegisterEffect(ge1,0)
 
	end
end
function c61100154.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) or c:IsLocation(LOCATION_GRAVE)
end
function c61100154.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		Duel.RegisterFlagEffect(tc:GetOwner(),61100154,RESET_PHASE+PHASE_END,0,1)
		tc=eg:GetNext()
	end
end
function c61100154.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(1-tp,61100154)>=5
end
function c61100154.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c61100154.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
			Duel.SpecialSummon(e:GetHandler(),0,tp,1-tp,false,false,POS_FACEUP)
		else
			local g=Duel.GetMatchingGroup(nil,1-tp,LOCATION_MZONE,0,nil)
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_RTOHAND)
			local sg=g:Select(1-tp,1,1,nil)
			Duel.HintSelection(sg)
			Duel.SendtoHand(sg,REASON_RULE,1-tp)
			Duel.SpecialSummon(e:GetHandler(),0,tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
function c61100154.tgfilter(c,ec)
	return not (ec:GetOwner()==c:GetControler() and c:IsLocation(LOCATION_HAND)) and ec~=c
end

function c61100154.e3cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ce=e:GetHandler()
	if chk==0 then return Duel.GetMatchingGroupCount(c61100154.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil,ce)>=2 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOHAND)
	local g=Duel.SelectMatchingCard(tp,c61100154.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,2,2,nil,ce)
	Duel.SendtoHand(g,c:GetOwner(),REASON_COST)
end

function c61100154.e3tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(1-c:GetControler(),LOCATION_MZONE)>0
	end
end

function c61100154.e3op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
		Duel.GetControl(c,1-c:GetControler())
	end
end