--无音的包围
local s,id,o=GetID()
local GIL_CODE=57300009

function s.initial_effect(c)
    aux.AddCodeList(c, GIL_CODE)
    
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SSET)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.setcon)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end

function s.gilfilter(c)
    return aux.IsCodeListed(c, GIL_CODE)
end

function s.mtfilter(c,e)
    return c:IsFaceup() and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c~=e:GetHandler()
end

function s.spfilter(c,e,tp)
    return s.gilfilter(c) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1 = Duel.IsExistingTarget(s.mtfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e)
        and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
    
    local b2 = Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
        and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
    
    if chk==0 then
        return b1 or b2
    end
    
    local op=0
    if b1 or b2 then
        op=aux.SelectFromOptions(tp,
            {b1,aux.Stringid(id,2),1},
            {b2,aux.Stringid(id,3),2})
    end
    e:SetLabel(op)
    
    if op==1 then
        if e:IsCostChecked() then
            e:SetCategory(CATEGORY_DISABLE)
            e:SetProperty(EFFECT_FLAG_CARD_TARGET)
            Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
        end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local g=Duel.SelectTarget(tp,s.mtfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e)
        Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
        
    elseif op==2 then
        if e:IsCostChecked() then
            e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
            e:SetProperty(0)
            Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
        end
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
        Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
    end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if e:GetLabel()==1 then
        local tc=Duel.GetFirstTarget()
        if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
        local c=e:GetHandler()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e2)
        
    elseif e:GetLabel()==2 then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
        if #g==0 then return end
        local tc=g:GetFirst()
        local c=e:GetHandler()
        
        Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetValue(1)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2)
        Duel.SpecialSummonComplete()
        
        if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
            local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
            if #dg>0 then
                Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
            end
        end
    end
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetTurnPlayer()~=tp then return false end
    local ph=Duel.GetCurrentPhase()
    if ph~=PHASE_MAIN1 and ph~=PHASE_MAIN2 then return false end
    local sum=Duel.GetActivityCount(tp,ACTIVITY_SUMMON)
    local flpsum=Duel.GetActivityCount(tp,ACTIVITY_FLIPSUMMON)
    local spsum=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
    return sum+flpsum+spsum>=5
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    if Duel.SSet(tp,c)>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
        e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
    end
end