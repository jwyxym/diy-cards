local s,id=GetID()
local ALMISS_LISTED = {
    65200270,
    65200280,
    65200290,
    65200300,
    65200310,
    65200320,
    65208330,
    65200340,
}

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost1)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.con2)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetValue(800)
    e3:SetCondition(s.con3)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e4)
end

function s.ritualfilter(c)
    return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_RITUAL)
end

function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
            or Duel.IsExistingMatchingCard(s.ritualfilter,tp,LOCATION_MZONE,0,1,nil)
    end
    Duel.ConfirmCards(1-tp,c)
    Duel.ShuffleHand(tp)
end

function s.filter(c)
    if c:IsCode(id) then return false end
    for _, code in ipairs(ALMISS_LISTED) do
        if c:IsCode(code) then return true end
    end
    return false
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
    if #g==0 then return end
    local tc=g:GetFirst()
    local has_almis=Duel.IsExistingMatchingCard(function(c) return c:IsCode(65200270) end,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
    if has_almis then
        local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
        if opt==0 then
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
        else
            Duel.SendtoGrave(tc,REASON_EFFECT)
        end
    else
        Duel.SendtoGrave(tc,REASON_EFFECT)
    end
end

function s.con2(e,tp)
    local c=e:GetHandler()
    return c:GetAttack()~=c:GetBaseAttack()
end

function s.spfilter(c,e,tp,max_lv)
    return c:IsRace(RACE_ZOMBIE) and c:GetLevel()<max_lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local max_lv=0
        local mg=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
        for tc in aux.Next(mg) do
            if tc:GetLevel()>max_lv then max_lv=tc:GetLevel() end
        end
        return max_lv>0
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,max_lv)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local max_lv=0
    local mg=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
    for tc in aux.Next(mg) do
        if tc:GetLevel()>max_lv then max_lv=tc:GetLevel() end
    end
    if max_lv<=0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,max_lv)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.con3(e)
    return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(65200270) end,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end