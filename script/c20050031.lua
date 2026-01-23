--致旧日的美梦
function c20050031.initial_effect(c)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(20050031)
	--change name
	aux.EnableChangeCode(c,19000032,LOCATION_MZONE+LOCATION_GRAVE)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c20050031.spcon)
	e2:SetTarget(c20050031.sptg)
	e2:SetOperation(c20050031.spop)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20050031,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(c20050031.thtg)
	e3:SetOperation(c20050031.thop)
	c:RegisterEffect(e3)
	--cannot be target
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(c20050031.atlimit)
	c:RegisterEffect(e4)
end
function c20050031.spfilter(c,tp)
	return c:IsFaceup() and (c:IsRace(RACE_ILLUSION) and c:IsAttack(600) and c:IsDefense(600)) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
function c20050031.spcon(e,c)
	if c==nil then return true end
	return Duel.IsExistingMatchingCard(c20050031.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetControler())
end
function c20050031.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(c20050031.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
function c20050031.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.SendtoGrave(g,REASON_SPSUMMON)
end
function c20050031.atfilter(c,atk)
	return c:IsFaceup() and c:IsRace(RACE_ILLUSION) and c:GetAttack()>atk
end
function c20050031.atlimit(e,c)
	return c:IsFaceup() and c:IsRace(RACE_ILLUSION) and Duel.IsExistingMatchingCard(c20050031.atfilter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetAttack())
end
function c20050031.thfilter(c)
	return c:IsAbleToHand() and c:IsCode(20050026,20050020)
end
function c20050031.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20050031.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c20050031.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c20050031.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end