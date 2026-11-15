local s,id=GetID()
local TOKEN_SKULL=65200900
local id_toki=65200090

function s.initial_effect(c)
    aux.AddCodeList(c, id_toki)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetHintTiming(0,TIMING_MAIN_END)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+1)
    e2:SetTarget(s.tktg)
    e2:SetOperation(s.tkop)
    c:RegisterEffect(e2)
    
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsMainPhase() then return false end
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    return g:FilterCount(function(tc) return not tc:IsRace(RACE_ZOMBIE) end,nil)==0
end

function s.costfilter(c)
    return c:IsRace(RACE_ZOMBIE) and c:IsReleasable()
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
    Duel.Release(g,REASON_COST)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.desfilter(c) return c:IsFaceup() and c:IsDefenseBelow(1500) end
function s.tokifilter(c,ec) return c~=ec and (c:IsCode(id_toki) or aux.IsCodeListed(c, id_toki)) end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    local has_toki = Duel.IsExistingMatchingCard(s.tokifilter,tp,LOCATION_ONFIELD,0,1,c,c)
    local max_des = has_toki and 2 or 1
    local dg = Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
    if #dg>0 and Duel.SelectYesNo(tp, aux.Stringid(id,2)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local sg = dg:Select(tp, 1, math.min(max_des, #dg), nil)
        if #sg>0 then Duel.HintSelection(sg) Duel.Destroy(sg,REASON_EFFECT) end
    end
end

function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end

function s.tkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local token=Duel.CreateToken(tp,TOKEN_SKULL)
    if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
        Duel.SpecialSummonComplete()
        
        if Duel.IsExistingMatchingCard(s.tokifilter,tp,LOCATION_ONFIELD,0,1,c,c) then
            local b1 = Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil)
            local b2 = Duel.IsExistingMatchingCard(Card.IsLinkSummonable,tp,LOCATION_EXTRA,0,1,nil,nil)
            
            if b1 and b2 then
                if Duel.SelectOption(tp, aux.Stringid(id,3), aux.Stringid(id,4))==0 then
                    Duel.BreakEffect()
                    local sg=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil):Select(tp,1,1,nil)
                    if sg:GetCount()>0 then Duel.SynchroSummon(tp,sg:GetFirst(),nil) end
                else
                    Duel.BreakEffect()
                    local sg=Duel.GetMatchingGroup(Card.IsLinkSummonable,tp,LOCATION_EXTRA,0,nil,nil):Select(tp,1,1,nil)
                    if sg:GetCount()>0 then Duel.LinkSummon(tp,sg:GetFirst(),nil) end
                end
            elseif b1 then
                Duel.BreakEffect()
                local sg=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil):Select(tp,1,1,nil)
                if sg:GetCount()>0 then Duel.SynchroSummon(tp,sg:GetFirst(),nil) end
            elseif b2 then
                Duel.BreakEffect()
                local sg=Duel.GetMatchingGroup(Card.IsLinkSummonable,tp,LOCATION_EXTRA,0,nil,nil):Select(tp,1,1,nil)
                if sg:GetCount()>0 then Duel.LinkSummon(tp,sg:GetFirst(),nil) end
            end
        end
    end
end