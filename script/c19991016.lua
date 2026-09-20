--爱丽丝，疯狂国度的迷途者
function c19991016.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19991016,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c19991016.spcon)
	c:RegisterEffect(e1)
	--direct attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(c19991016.dircon)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_NONTUNER)
	e3:SetValue(c19991016.tnval)
	c:RegisterEffect(e3)
	--Special Summon
	local e4=Effect.CreateEffect(c)
	e4:SetCountLimit(1,19991016)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e4:SetTarget(c19991016.spstg)
	e4:SetOperation(c19991016.spsop)
	c:RegisterEffect(e4)
end
function c19991016.filter(c)
	return c:IsCode(19991003) and c:IsFaceup()
end
function c19991016.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c19991016.filter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
function c19991016.dircon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(c19991016.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c19991016.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c19991016.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c19991016.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end