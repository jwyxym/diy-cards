--大千录 切手剁肢
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(this.atg)
    e1:SetOperation(this.aop)
    c:RegisterEffect(e1)
    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+1+EFFECT_COUNT_CODE_OATH)
    e3:SetCondition(this.spcon)
	e3:SetTarget(this.sptg)
	e3:SetOperation(this.spop)
	c:RegisterEffect(e3)
end
function this.atg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) end
    if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tc,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function this.aop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)>0 then
        Duel.BreakEffect()
        Duel.Damage(tp,1000,REASON_EFFECT,true)
        Duel.Damage(1-tp,500,REASON_EFFECT,true)
        Duel.RDComplete()
    end
end
function this.spafilter(c)
    return c:IsSetCard(0x3980) and c:IsFaceup()
end
function this.spfilter(c,e,tp)
	return c:IsSetCard(0x3980) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function this.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(this.spafilter,tp,LOCATION_MZONE,0,1,nil) and (Duel.GetTurnCount()~=e:GetHandler():GetTurnID() or e:GetHandler():IsReason(REASON_RETURN))
end
function this.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(this.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function this.spop(e,tp,eg,ep,ev,re,r,rp)local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)>0 then
	    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	    local g=Duel.SelectMatchingCard(tp,this.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	    if g:GetCount()>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	    end
    end
end
