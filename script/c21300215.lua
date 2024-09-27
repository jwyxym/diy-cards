--晨跃 懒散少女
local this,id,ofs=GetID()
function this.initial_effect(c)
	aux.EnablePendulumAttribute(c)
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(this.spcon)
	e1:SetCost(this.spcost)
	e1:SetTarget(this.sptg)
	e1:SetOperation(this.spop)
	c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_PZONE,0)
	e1:SetValue(this.mtval)
	c:RegisterEffect(e1)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+1+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(this.sprcon)
	e1:SetOperation(this.sprop)
	e1:SetValue(this.sprval)
	c:RegisterEffect(e1)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id+2)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetTarget(this.thtg)
    e1:SetOperation(this.thop)
    c:RegisterEffect(e1)

	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,this.regfilter)
end
function this.regfilter(c)
	if c:IsSummonLocation(LOCATION_EXTRA) then
		return c:IsRace(RACE_CYBERSE)
	else return true
	end
end
function this.spfilter(c,seq)
	return c:GetSequence()==seq
end
function this.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(this.spfilter,tp,LOCATION_MZONE,0,1,nil,c:GetSequence());
end
function this.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(this.splimit)
	Duel.RegisterEffect(e1,tp)
end
function this.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE) and c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION+TYPE_LINK)
end
function this.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetMZoneCount(tp)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function this.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function this.mtval(e,c)
	if not c then return true end
	return true --c:IsRace(RACE_CYBERSE)
end
function this.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=0
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_SZONE,0,nil)
	for tc in aux.Next(g) do
		zone=zone|(1<<tc:GetSequence())
	end
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
function this.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(this.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function this.sprval(e,c)
	local tp=c:GetControler()
	local zone=0
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_SZONE,0,nil)
	for tc in aux.Next(g) do
		zone=zone|(1<<tc:GetSequence())
	end
	return 0,zone
end
function this.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not rc:IsAttribute(ATTRIBUTE_WIND) and not rc:IsSummonLocation(LOCATION_EXTRA)
end
function this.thfilter(c)
    return c:IsSetCard(0x677) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function this.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function this.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local tc=Duel.SelectMatchingCard(tp,this.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if tc then
        Duel.SendtoHand(tc,tp,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end
end
