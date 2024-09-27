--陨宇祀圣 炽锻
local this,id,ofs=GetID()
function this.initial_effect(c)
	aux.EnablePendulumAttribute(c)
    c:EnableReviveLimit()
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(this.sptg)
    e1:SetOperation(this.spop)
    c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCountLimit(1,id+1)
	e3:SetRange(LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_HAND)
	e3:SetCondition(this.sprcon)
	e3:SetTarget(this.sprtg)
	e3:SetOperation(this.sprop)
	c:RegisterEffect(e3)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(this.desreptg)
	e2:SetValue(this.desrepval)
	e2:SetOperation(this.desrepop)
	c:RegisterEffect(e2)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCountLimit(1,id+2)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(this.tg)
	e1:SetOperation(this.op)
	c:RegisterEffect(e1)
	local e1=e1:Clone()
	e1:SetCode(EVENT_TO_DECK)
	e1:SetCondition(this.con)
	c:RegisterEffect(e1)
end
function this.spfilter(c,e,tp)
    return c:IsSetCard(0xa63) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function this.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
    and e:GetHandler():IsDestructable() and Duel.GetMZoneCount(tp)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function this.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(this.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if tc and #tc==1 and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
    and c:IsRelateToEffect(e) then
        Duel.BreakEffect()
        Duel.Destroy(c,REASON_EFFECT)
    end
end
function this.sprfilter(c)
	return (c:IsSetCard(0xa63) or c:IsRace(RACE_ROCK)) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function this.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(this.sprfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	return ((c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) or
		(c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0))
		and g:IsExists(this.sprfilter,2,c)
end
function this.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(this.sprfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:Select(tp,2,2,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function this.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
function this.repfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and (c:IsSetCard(0xa63) or c:IsRace(RACE_ROCK))
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function this.repfilter2(c)
    return c:IsSetCard(0xa63) and c:IsAbleToRemove()
end
function this.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(this.repfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(this.repfilter2),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function this.desrepval(e,c)
	return this.repfilter(c,e:GetHandlerPlayer())
end
function this.desrepop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(this.repfilter2),tp,LOCATION_ONFIELD,LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	Duel.Hint(HINT_CARD,0,id)
end
function this.filter(c,e,tp)
	return c:IsSetCard(0xa63) and (c:IsLevelBelow(8) or c:IsRankBelow(4)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and this.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(this.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,this.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function this.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()
end
