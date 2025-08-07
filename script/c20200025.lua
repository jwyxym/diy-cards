--疯狂国度的疯帽子
function c20200025.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--indes
	aux.EnableChangeCode(c,20200003,LOCATION_PZONE)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20200025,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c20200025.spcon)
	c:RegisterEffect(e1)
	--direct attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(c20200025.dircon)
	c:RegisterEffect(e2)
	--spsummon1
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20200025,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e3:SetCountLimit(1,20200025)
	e3:SetCost(c20200025.spcost)
	e3:SetTarget(c20200025.sptg)
	e3:SetOperation(c20200025.spop)
	c:RegisterEffect(e3)
	--spsummon2
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(20200025,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1,20200025+100)
	e4:SetCost(c20200025.spscon)
	e4:SetTarget(c20200025.sptg)
	e4:SetOperation(c20200025.spop)
	c:RegisterEffect(e4)
end
function c20200025.spfilter(c)
	return c:IsCode(20200003) and c:IsFaceup()
end
function c20200025.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c20200025.spfilter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
function c20200025.dircon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(c20200025.spfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c20200025.costfilter(c)
	return c:IsCode(20200003) and c:IsAbleToGraveAsCost()
end
function c20200025.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20200025.costfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c20200025.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function c20200025.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c20200025.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c20200025.cfilter(c)
	return c:IsFaceup() and c:IsCode(20200003)
end
function c20200025.spscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c20200025.cfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end