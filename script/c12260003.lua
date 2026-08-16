--山水-秀木
local s,id=GetID()
function s.initial_effect(c)
	--spsummon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES+CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
    e1:SetCondition(s.spcon)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --sset then boom
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.setcon)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
        and Duel.GetTurnPlayer()==tp or Duel.GetTurnPlayer()==1-tp
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return not Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
    return true
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
            and (not Duel.IsPlayerCanDiscardDeck(tp,1) 
                or Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil))
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.spfilter(c,e,tp)
    return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsType(TYPE_NORMAL) or c:IsCanBeSpecialSummoned(e,0,tp,true,false))
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    if #g>0 then
        local tc=g:GetFirst()
        local pos=0
        local options={}
        if not tc:IsHasEffect(EFFECT_CANNOT_BE_EFFECT_TARGET) then
            table.insert(options,aux.Stringid(id,2)) 
        end
        table.insert(options,aux.Stringid(id,3)) 
        local op=Duel.SelectOption(tp,table.unpack(options))+1
        if op==1 then
            if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_DISABLE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e1)
                local e2=Effect.CreateEffect(c)
                e2:SetType(EFFECT_TYPE_SINGLE)
                e2:SetCode(EFFECT_DISABLE_EFFECT)
                e2:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e2)
            end
        else
            Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEDOWN_DEFENSE)
            Duel.ConfirmCards(1-tp,tc)
        end
        if Duel.IsPlayerCanDiscardDeck(tp,1) 
            and Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) then
            if Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
                Duel.BreakEffect()
                Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST+REASON_DISCARD)
                local sc=Duel.GetFirstMatchingCard(s.setfilter,tp,LOCATION_DECK,0,nil)
                if sc then
                    Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
                end
            end
        end
    end
end

function s.setfilter(c)
    return c:IsCode(12260008) and c:IsType(TYPE_SPELL+TYPE_TRAP) 
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousPosition(POS_FACEDOWN) and c:IsPreviousLocation(LOCATION_MZONE)
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SEARCH,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_ONFIELD)
end

function s.stfilter(c)
    return c:IsSetCard(0x63a0) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SSet(tp,g:GetFirst())
        local fc=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_ONFIELD,0,nil)
        if fc>=2 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
            if #dg>0 then
                Duel.HintSelection(dg)
                Duel.Destroy(dg,REASON_EFFECT)
            end
        end
    end
end