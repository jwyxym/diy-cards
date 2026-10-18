local s,id=GetID()
local HOLY=0x474
local TWILIGHT=0x747

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(2,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.lightfilter)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetTarget(s.darkfilter)
    e4:SetValue(aux.indoval)
    c:RegisterEffect(e4)

    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_UPDATE_ATTACK)
    e5:SetRange(LOCATION_MZONE)
    e5:SetTargetRange(LOCATION_MZONE,0)
    e5:SetTarget(s.lightdarkfilter)
    e5:SetValue(500)
    c:RegisterEffect(e5)

    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetCode(EFFECT_ADD_ATTRIBUTE)
    e6:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e6:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(e6)
end

function s.lightfilter(e,c)
    return c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.darkfilter(e,c)
    return c:IsAttribute(ATTRIBUTE_DARK)
end
function s.lightdarkfilter(e,c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK)
end

function s.filter(c)
    return c:IsFaceup() and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
    local kind=tc:GetOriginalType()
    Duel.SendtoGrave(tc,REASON_EFFECT)

    if kind&TYPE_MONSTER>0 then
        if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsAbleToHand() then
            Duel.SendtoHand(c,nil,REASON_EFFECT)
        end
    elseif kind&TYPE_SPELL>0 then
        local lv=c:GetLevel()
        local g=Duel.GetMatchingGroup(s.synfilter,tp,LOCATION_EXTRA,0,nil,e,tp,lv)
        if #g>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
            Duel.SendtoGrave(c,REASON_EFFECT)
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg=g:Select(tp,1,1,nil)
            if #sg>0 then
                Duel.SpecialSummon(sg,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
            end
        end
    elseif kind&TYPE_TRAP>0 then
        local rank=c:GetLevel()
        local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,e,tp,rank)
        if #g>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg=g:Select(tp,1,1,nil)
            if #sg>0 then
                local xyz=sg:GetFirst()
                Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
                Duel.Overlay(xyz,c)
            end
        end
    end
end

function s.synfilter(c,e,tp,lv)
    return c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_SYNCHRO) and c:IsSetCard(HOLY) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.xyzfilter(c,e,tp,rank)
    return c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_XYZ) and c:IsSetCard(TWILIGHT) and c:GetRank()==rank and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end