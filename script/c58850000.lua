local s,id=GetID()
local id_inf = 58850000

function s.initial_effect(c)
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCountLimit(1)
    e0:SetTarget(s.thtg)
    e0:SetOperation(s.thop)
    c:RegisterEffect(e0)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,4))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.desreptg)
    e2:SetValue(s.desrepval)
    e2:SetOperation(s.desrepop)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,5))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EFFECT_REMOVE_REPLACE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.remreptg)
    e3:SetValue(s.remrepval)
    e3:SetOperation(s.remrepop)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetRange(LOCATION_FZONE)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetTarget(aux.TargetBoolFunction(s.atkfilter))
    e4:SetValue(s.atkval)
    c:RegisterEffect(e4)

    local e5=e4:Clone()
    e5:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e5)
end

function s.thfilter(c)
    return (c:IsCode(id_inf) or aux.IsCodeListed(c, id_inf)) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsAbleToGrave())
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(tp,id) > 0 then return end
    if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then return end
    
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    if not Duel.SelectYesNo(tp, aux.Stringid(id,3)) then return end 
    
    local op = Duel.SelectOption(tp, aux.Stringid(id,1), aux.Stringid(id,2))
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        local tc=g:GetFirst()
        if op==0 then
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
        else
            Duel.SendtoGrave(tc,REASON_EFFECT)
        end
    end
end

function s.atkfilter(c)
    local code = c:GetCode()
    return aux.IsCodeListed(c, id_inf) or (code >= 58850010 and code <= 58850210)
end

function s.check_synchro(c)
    return c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end

function s.desrepfilter(c,e,tp)
    return s.atkfilter(c) and c:IsReason(REASON_EFFECT)
end

function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=eg:Filter(s.desrepfilter,nil)
    if chk==0 then 
        return #g>0 and Duel.IsExistingMatchingCard(s.check_synchro,tp,LOCATION_MZONE,0,1,nil) 
    end
    g:KeepAlive()
    e:SetLabelObject(g)
    return Duel.SelectYesNo(tp, aux.Stringid(id, 4))
end

function s.desrepval(e,c)
    return s.desrepfilter(c)
end

function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.SendtoGrave(c, REASON_EFFECT+REASON_REPLACE)
    local g=e:GetLabelObject()
    if g then g:DeleteGroup() end
end

function s.remrepfilter(c,e,tp)
    return s.atkfilter(c) and c:IsReason(REASON_EFFECT)
end

function s.remreptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=eg:Filter(s.remrepfilter,nil)
    if chk==0 then 
        return #g>0 and Duel.IsExistingMatchingCard(s.check_synchro,tp,LOCATION_MZONE,0,1,nil) 
    end
    g:KeepAlive()
    e:SetLabelObject(g)
    return Duel.SelectYesNo(tp, aux.Stringid(id, 5))
end

function s.remrepval(e,c)
    return s.remrepfilter(c)
end

function s.remrepop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.SendtoGrave(c, REASON_EFFECT+REASON_REPLACE)
    local g=e:GetLabelObject()
    if g then g:DeleteGroup() end
end

function s.atkval(e,c)
    local tp=e:GetHandlerPlayer()
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,nil)
    local count=0
    for tc in aux.Next(g) do
        if s.atkfilter(tc) then
            count=count+1
        end
    end
    return count*200
end