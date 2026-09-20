local s,id=GetID()
local SET_HOLY_NIGHT=0x159

function s.initial_effect(c)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCountLimit(1,id)
    c:RegisterEffect(e0)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetOperation(s.regflag)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id+2)
    e2:SetCondition(s.sumcon)
    e2:SetTarget(s.sumtg)
    e2:SetOperation(s.sumop)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAIN_SOLVED)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,id+1)
    e3:SetCondition(s.eff2con)
    e3:SetTarget(s.eff2tg)
    e3:SetOperation(s.eff2op)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e4:SetRange(LOCATION_SZONE)
    e4:SetTargetRange(0,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND)
    e4:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(e4)

    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e5:SetRange(LOCATION_SZONE)
    e5:SetTargetRange(1,0)
    e5:SetTarget(s.xyzlimit)
    c:RegisterEffect(e5)
end

function s.regflag(e,tp,eg,ep,ev,re,r,rp)
    for tc in aux.Next(eg) do
        if tc:IsControler(tp) and not tc:IsType(TYPE_XYZ) then
            Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
            return
        end
    end
end

function s.sumcon(e,tp)
    return Duel.IsMainPhase() and Duel.GetFlagEffect(tp,id)==0
end
function s.sumfilter(c)
    return c:IsSetCard(SET_HOLY_NIGHT) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.lightlimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

function s.eff2con(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsAttribute(ATTRIBUTE_DARK)
        and Duel.GetFlagEffect(tp,id)==0
end
function s.eff2tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local b1=Duel.IsExistingMatchingCard(s.lightfilter,tp,LOCATION_MZONE,0,1,nil)
        local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
        return b1 and b2
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.eff2op(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.xyzlimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g1=Duel.SelectMatchingCard(tp,s.lightfilter,tp,LOCATION_MZONE,0,1,1,nil)
    if #g1==0 then return end
    if Duel.SendtoHand(g1,nil,REASON_EFFECT)==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g2=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    if #g2>0 then
        Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.lightfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.lightlimit(e,c)
    return not c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.xyzlimit(e,c)
    return not c:IsType(TYPE_XYZ)
end