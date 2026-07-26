--带来静寂的拔刀
local s,id,o=GetID()
local GIL_CODE=57300009

function s.initial_effect(c)
    aux.AddCodeList(c, GIL_CODE)
    
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
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
    local has_gil = Duel.IsExistingMatchingCard(s.gilfilter,tp,LOCATION_MZONE,0,1,nil)
    local b1 = has_gil
        and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
        and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
    
    local t1,t2,t3=Duel.GetActivityCount(tp,ACTIVITY_SUMMON,ACTIVITY_FLIPSUMMON,ACTIVITY_SPSUMMON)
    local b2 = t1+t2+t3>=5
        and Duel.IsPlayerCanDraw(tp,1)
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
            e:SetCategory(CATEGORY_DESTROY)
            e:SetProperty(EFFECT_FLAG_CARD_TARGET)
            Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
        end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
        
    elseif op==2 then
        if e:IsCostChecked() then
            e:SetCategory(CATEGORY_DRAW)
            e:SetProperty(0)
            Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
        end
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if e:GetLabel()==1 then
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
            Duel.Destroy(tc,REASON_EFFECT)
        end
        
    elseif e:GetLabel()==2 then
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    local t1,t2,t3=Duel.GetActivityCount(tp,ACTIVITY_SUMMON,ACTIVITY_FLIPSUMMON,ACTIVITY_SPSUMMON)
    return t1+t2+t3>=5
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
        e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
        e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
    end
end
