--谋略谍报兵

local s,id=GetID()
local TOKEN_CODE=57300024
local GIL_CODE=57300009

function s.initial_effect(c)
    aux.AddCodeList(c, GIL_CODE)
    
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES+CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon1)
    e1:SetCost(s.spcost1)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)
    
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.spcon2)
    e2:SetCost(s.spcost2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
end

function s.isCodeListed(c)
    return aux.IsCodeListed(c, GIL_CODE)
end

function s.gilfilter(c)
    return c:IsFaceup() and s.isCodeListed(c)
end

function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.gilfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return e:GetHandler():IsLocation(LOCATION_HAND)
    end
    Duel.ConfirmCards(1-tp,e:GetHandler())
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
    
    if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
        if #hg>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
            local dg=hg:Select(tp,1,1,nil)
            if #dg>0 then
                Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
                if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
                    local token=Duel.CreateToken(tp,TOKEN_CODE)
                    if token then
                        Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
                    end
                end
            end
        end
    end
end

function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    local summon_count=Duel.GetActivityCount(tp,ACTIVITY_SUMMON)
    local spsummon_count=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
    return summon_count+spsummon_count>=5 and Duel.GetTurnPlayer()==tp
end

function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

function s.gilmonfilter(c,e,tp)
    return s.isCodeListed(c) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(s.gilmonfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    
    local g=Duel.GetMatchingGroup(s.gilmonfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
    if #g==0 then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=g:Select(tp,1,1,nil)
    if #sg>0 then
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end
end
