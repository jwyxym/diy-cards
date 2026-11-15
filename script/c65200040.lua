local s,id=GetID()
local TOKEN_SKULL=65200900
local id_toki=65200090

function s.initial_effect(c)
    aux.AddCodeList(c, id_toki)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOKEN)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.gycon)
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)
end

function s.tokifilter(c)
    return c:IsCode(id_toki) or aux.IsCodeListed(c, id_toki)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.tokifilter,tp,LOCATION_ONFIELD,0,1,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.desfilter(c)
    return c:IsFaceup() and c:IsDefenseBelow(1500)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local loc = c:GetLocation()
    if not c:IsRelateToEffect(e) then return end
    
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        if loc==LOCATION_GRAVE then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(LOCATION_REMOVED)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
            c:RegisterEffect(e1)
        end

        local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
        if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local sg=g:Select(tp,1,1,nil)
            if #sg>0 then
                Duel.HintSelection(sg)
                Duel.Destroy(sg,REASON_EFFECT)
            end
        end
    end
end

-- ★ 修复：增加从手卡被解放的判定
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return (c:IsPreviousLocation(LOCATION_HAND) and c:IsReason(REASON_RELEASE)) 
        or (c:IsPreviousLocation(LOCATION_MZONE) and (c:IsReason(REASON_RELEASE) or c:IsReason(REASON_EFFECT) or c:IsReason(REASON_BATTLE)))
end

function s.thfilter(c)
    return (c:IsCode(id_toki) or aux.IsCodeListed(c, id_toki)) and not c:IsCode(id) and c:IsAbleToGrave()
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
        
        if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_SKULL,0,TYPES_TOKEN,1000,1000,1,RACE_ZOMBIE,ATTRIBUTE_DARK) then
            Duel.BreakEffect()
            local token=Duel.CreateToken(tp,TOKEN_SKULL)
            Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end