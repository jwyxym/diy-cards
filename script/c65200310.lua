local s,id=GetID()

function s.initial_effect(c)
    aux.AddCodeList(c, 65200270)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.setcon)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end

function s.rmfilter(c)
    return c:IsFaceup() and c:IsAbleToRemove()
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local race=tc:GetRace()
    if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)==0 then return end

    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft>0 then
        local f=function(c) return c:IsRace(race) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
        local g=Duel.GetMatchingGroup(f,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
        if g:GetCount()>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg=g:Select(tp,1,1,nil)
            if #sg>0 then
                Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
            end
        end
    end

    local rg=Duel.GetMatchingGroup(function(c)
        return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_RITUAL)
            and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
    end,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
    if rg:GetCount()==0 then return end
    if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local rc=rg:Select(tp,1,1,nil):GetFirst()
    if not rc then return end
    local rlevel=rc:GetLevel()
    if rlevel<=0 then return end

    local mg=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
    if mg:GetCount()==0 then return end

    local high=mg:Filter(function(c) return c:GetLevel()>=rlevel end,nil)
    local sg
    if high:GetCount()>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
        sg=high:Select(tp,1,1,nil)
    else
        sg=Group.CreateGroup()
        local sum=0
        while sum<rlevel do
            local avail=mg:Filter(function(c) return not sg:IsContains(c) end,nil)
            if avail:GetCount()==0 then return end
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
            local sel=avail:Select(tp,1,1,nil)
            if sel:GetCount()==0 then return end
            local tc=sel:GetFirst()
            sg:AddCard(tc)
            sum=sum+tc:GetLevel()
        end
    end
    if sg:GetCount()==0 then return end

    Duel.Release(sg,REASON_COST+REASON_MATERIAL+REASON_RITUAL)
    if Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP) then
        rc:CompleteProcedure()
    end
end

function s.setcon(e,tp)
    return Duel.IsExistingMatchingCard(function(c)
        return c:IsFaceup() and c:IsCode(65200270)
    end,tp,LOCATION_MZONE,0,1,nil)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.SSet(tp,c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetValue(LOCATION_REMOVED)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e1)
end