local s,id=GetID()
local NM=0x32a

if not _G.NM_DMG_65200240 then
    _G.NM_DMG_65200240 = true
    local ge=Effect.GlobalEffect()
    ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge:SetCode(EVENT_DAMAGE)
    ge:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        if ep==tp then
            Duel.RegisterFlagEffect(tp, 65200240, RESET_PHASE+PHASE_END, 0, 1)
        end
    end)
    Duel.RegisterEffect(ge, 0)
end

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+100)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- ③ 永续效果：守备1500以下的怪兽从场上离开时自动给持有者400伤害
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_DAMAGE)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetRange(LOCATION_MZONE)
    e4:SetOperation(s.damop)
    c:RegisterEffect(e4)
end

function s.spfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsLevelBelow(4)
end
function s.spcon(e,tp)
    return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.thfilter(c)
    return c:IsSetCard(NM) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.disfilter(c)
    return c:IsFaceup()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,400)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Damage(tp,400,REASON_EFFECT)
    if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end

    local ct=Duel.GetFlagEffect(tp,65200240)
    if ct>0 then
        local dg=Duel.GetMatchingGroup(s.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
        if dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            local num=math.min(ct,dg:GetCount())
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
            local sg=dg:Select(tp,1,num,nil)
            for tc in aux.Next(sg) do
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_DISABLE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e1)
                local e2=e1:Clone()
                e2:SetCode(EFFECT_DISABLE_EFFECT)
                tc:RegisterEffect(e2)
            end
        end
    end
end

-- ③ 永续效果处理：自动给离场怪兽的持有者400伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    local tc=eg:GetFirst()
    while tc do
        if tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsDefenseBelow(1500) then
            Duel.Damage(tc:GetOwner(),400,REASON_EFFECT)
        end
        tc=eg:GetNext()
    end
end