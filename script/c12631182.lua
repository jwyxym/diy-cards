-- 灰灭都的悼亡伶
local s,id,o=GetID()
local SET_HAIMETSU=0x1ad
local CARD_HAIMETSU_CITY=3055018

function s.initial_effect(c)
    aux.AddCodeList(c,CARD_HAIMETSU_CITY)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.sprcon)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
    e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id+o)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
end

function s.sprfilter(c)
    return c:IsFaceup() and c:IsCode(CARD_HAIMETSU_CITY)
end

function s.sprcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.sprfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_HAIMETSU) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

function s.ssfilter(c,tp)
    return c:IsSetCard(SET_HAIMETSU) and c:IsType(TYPE_SPELL+TYPE_TRAP)
        and c:IsSSetable()
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    if Duel.IsExistingMatchingCard(s.sprfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
        and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,tp)
        and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tp)
        if #g>0 then
            Duel.SSet(tp,g:GetFirst())
        end
    end
end
