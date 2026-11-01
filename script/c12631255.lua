-- 魅魇的蚀梦低语
local s,id,o=GetID()
local SET_MIYAN=0xfa3

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_CONTROL)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id+o)
    e2:SetCondition(s.ctlcon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.ctltg)
    e2:SetOperation(s.ctlop)
    c:RegisterEffect(e2)
end

s.listed_series={SET_MIYAN}

function s.def0filter(c)
    return c:IsFaceup() and not c:IsType(TYPE_LINK) and c:GetDefense()==0
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    if not re or rp==tp then return false end
    return Duel.IsExistingMatchingCard(s.def0filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_MIYAN) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return not c:IsRace(RACE_FIEND)
end

function s.miyanfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_MIYAN) and c:IsType(TYPE_MONSTER)
end

function s.ctlcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.miyanfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.ctlfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER)
        and not c:IsType(TYPE_LINK) and c:GetDefense()==0
end

function s.ctltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.ctlfilter(chkc) end
    if chk==0 then
        return Duel.IsExistingTarget(s.ctlfilter,tp,0,LOCATION_MZONE,1,nil)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local g=Duel.SelectTarget(tp,s.ctlfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end

function s.ctlop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.GetControl(tc,tp)
    end
end
