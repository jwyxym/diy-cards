--唇音的协调
local s,id,o=GetID()
local GIL_CODE=57300009

function s.initial_effect(c)
    aux.AddCodeList(c, GIL_CODE)
    
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_SEARCH)
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

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1 = Duel.IsExistingMatchingCard(s.gilfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
        and Duel.IsPlayerCanDraw(tp,1)
        and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
    
    local b2 = Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.gilfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
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
            e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
            e:SetProperty(EFFECT_FLAG_CARD_TARGET)
            Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
        end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g=Duel.SelectTarget(tp,s.gilfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,3,nil)
        Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
        
    elseif op==2 then
        if e:IsCostChecked() then
            e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
            e:SetProperty(0)
            Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
        end
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
    end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if e:GetLabel()==1 then
       
        local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
        if not g or #g==0 then return end
        local tg=g:Filter(Card.IsRelateToEffect,nil,e)
        if #tg==0 then return end
        if Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
        Duel.BreakEffect()
        Duel.Draw(tp,1,REASON_EFFECT)
        
    elseif e:GetLabel()==2 then
        
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.gilfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
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
