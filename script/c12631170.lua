--制冷机块 艾斯科熊
local s,id=GetID()
local SET_KIHAI=0x014b

function s.initial_effect(c)
    aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_KIHAI),2,99)
    c:EnableReviveLimit()

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
    e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,id+200)
    e3:SetCondition(s.thcon)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

s.listed_series={SET_KIHAI}

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.spfilter(c,e,tp,zone)
    return c:IsSetCard(SET_KIHAI) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
    if chk==0 then
        return zone~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local zone=bit.band(c:GetLinkedZone(tp),0x1f)
    if zone==0 then return end

    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
    if ft<=0 then return end

    if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
    local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp,zone)
    local g=nil
    if tg:GetCount()>ft then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        g=tg:Select(tp,ft,ft,nil)
    else
        g=tg
    end
    if g:GetCount()>0 then
        for tc in aux.Next(g) do
            Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP,zone)
        end
        Duel.SpecialSummonComplete()
    end

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function() return true end)
    Duel.RegisterEffect(e1,tp)
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsFaceup() or c:GetMutualLinkedGroupCount()==0 then return false end
    if rp==tp or not re then return false end
    return true
end

function s.dfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end

function s.sfilter(c,p,seq,loc)
    local sseq=c:GetSequence()
    if c:IsControler(1-p) then
        return loc==LOCATION_MZONE and c:IsLocation(LOCATION_MZONE)
            and (sseq==5 and seq==3 or sseq==6 and seq==1)
    end
    if c:IsLocation(LOCATION_SZONE) then
        return sseq<5 and (sseq==seq or loc==LOCATION_SZONE and math.abs(sseq-seq)==1)
    end
    if sseq<5 then
        return sseq==seq or loc==LOCATION_MZONE and math.abs(sseq-seq)==1
    else
        return loc==LOCATION_MZONE and (sseq==5 and seq==1 or sseq==6 and seq==3)
    end
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.dfilter(chkc) end
    if chk==0 then
        return Duel.IsExistingTarget(s.dfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local tc=Duel.SelectTarget(tp,s.dfilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
    e:SetLabelObject(tc)
    local g=Duel.GetMatchingGroup(s.sfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,tc:GetControler(),tc:GetSequence(),tc:GetLocation())
    g:AddCard(tc)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local g=Duel.GetMatchingGroup(s.sfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,tc,tc:GetControler(),tc:GetSequence(),tc:GetLocation())
    g:AddCard(tc)
    Duel.Destroy(g,REASON_EFFECT)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsFaceup() and c:GetMutualLinkedGroupCount()==0
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and chkc:IsAbleToHand() end
    if chk==0 then
        return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end
end