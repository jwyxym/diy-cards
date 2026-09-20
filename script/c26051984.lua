-- 跃音萌行 宙间鸣响
-- ID: 26051984
-- 字段：跃音萌行 0x906
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.setcon)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x906) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
            local mg=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,0,nil)
            if #mg>0 then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
                local sg=mg:Select(tp,1,1,nil)
                Duel.SendtoHand(sg,nil,REASON_EFFECT)
            end
        end
    end
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    local c=eg:GetFirst()
    while c do
        if c:IsSetCard(0x906) and c:IsFaceup() and c:IsPreviousLocation(LOCATION_MZONE) then
            local rsn=c:GetReason()
            if bit.band(rsn,REASON_BATTLE)~=0 then return true end
            if bit.band(rsn,REASON_EFFECT)~=0 and c:GetReasonPlayer()==1-tp then return true end
        end
        c=eg:GetNext()
    end
    return false
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    local c=e:GetHandler()
    Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
    Duel.ConfirmCards(1-tp,c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetValue(LOCATION_REMOVED)
    c:RegisterEffect(e1)
end