--穹瀛共舞
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(this.tgtg)
    e1:SetOperation(this.tgop)
    c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+ofs)
	e2:SetCondition(this.spcon)
	e2:SetTarget(this.sptg)
	e2:SetOperation(this.spop)
	c:RegisterEffect(e2)
end
function this.tgfilter(c)
    return c:IsSetCard(0x675) and c:IsAbleToGrave()
end
function this.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.tgfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetMZoneCount(tp)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,21300355,0x675,TYPES_TOKEN_MONSTER,0,0,1,RACE_WYRM,ATTRIBUTE_WATER) end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function this.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,this.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
	    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
        or not Duel.IsPlayerCanSpecialSummonMonster(tp,21300355,0x675,TYPES_TOKEN_MONSTER,0,0,1,RACE_WYRM,ATTRIBUTE_WATER) then return end
        Duel.BreakEffect()
        local token=Duel.CreateToken(tp,21300355)
	    Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
function this.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSummonPlayer(1-tp)
end
function this.spfilter(c,e,tp)
    return Duel.IsExistingMatchingCard(this.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetOriginalRace(),c:GetOriginalAttribute())
end
function this.spfilter2(c,e,tp,race,attr)
    return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetOriginalRace()==race and c:GetOriginalAttribute()~=attr
end
function this.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(this.cfilter,1,nil,tp) and rp==1-tp
end
function this.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and this.spfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(this.spfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) and Duel.GetMZoneCount(tp)>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,this.spfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function this.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end
    if Duel.GetMZoneCount(tp)==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=Duel.SelectMatchingCard(tp,this.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetOriginalRace(),tc:GetOriginalAttribute()):GetFirst()
    Duel.SpecialSummon(sc,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP)
end
