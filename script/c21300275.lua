--晨跃 光溟之兽
local this,id,ofs=GetID()
function this.initial_effect(c)
	aux.AddFusionProcFunFun(c,this.matfilter1,this.matfilter2,2,false,true)
    c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,id)
	e1:SetTarget(this.esptg)
	e1:SetOperation(this.espop)
	c:RegisterEffect(e1)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id+1)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(this.spcon)
    e1:SetTarget(this.sptg)
    e1:SetOperation(this.spop)
    c:RegisterEffect(e1)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCondition(this.descon)
    e1:SetTarget(this.destg)
    e1:SetOperation(this.desop)
    c:RegisterEffect(e1)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(this.matcon)
	e5:SetOperation(this.matop)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_MATERIAL_CHECK)
	e6:SetValue(this.valcheck)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(this.pencon)
	e5:SetTarget(this.tptg)
	e5:SetOperation(this.tpop)
	c:RegisterEffect(e5)
end
function this.matfilter1(c)
    return c:IsFusionSetCard(0x677) and c:IsFusionType(TYPE_FUSION)
end
function this.matfilter2(c)
    return c:IsRace(RACE_CYBERSE) and c:IsFusionType(TYPE_LINK)
end
function this.espfilter(c,e,tp)
    return c:IsAttackBelow(2300) and c:IsRace(RACE_CYBERSE) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function this.esptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.espfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function this.espop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,this.espfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 and e:GetHandler():IsRelateToEffect(e) then
		Duel.BreakEffect()
        Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
function this.spfilter(c,e,tp)
    return c:IsRace(RACE_CYBERSE) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function this.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function this.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
        and Duel.GetMZoneCount(tp)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)    
end
function this.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,this.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if tc then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
    end
end
function this.descon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and e:GetHandler():GetFlagEffectLabel(id+1) and e:GetHandler():GetFlagEffectLabel(id+1)>0
end
function this.destg(e,tp,g,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsOnField() end
    if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
        and c:GetFlagEffect(id)<c:GetFlagEffectLabel(id+1) end
    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
function this.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end
function this.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()>0
end
function this.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,0,1,e:GetLabel())
end
function this.valcheck(e,c)
	local g=c:GetMaterial()
	local ct=g:FilterCount(Card.IsFusionAttribute,nil,ATTRIBUTE_WIND)
	e:GetLabelObject():SetLabel(ct)
end
function this.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function this.tptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function this.tpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
