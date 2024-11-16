--烬海龙·炽射
local s,id,o=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetTarget(s.tg)
    e1:SetOperation(s.op)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EVENT_FLIP)
    c:RegisterEffect(e3)
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_SPSUMMON_PROC)
    e4:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e4:SetRange(LOCATION_HAND)
    e4:SetCondition(s.spcon)
    c:RegisterEffect(e4)
    if not s.global_check then
        s.global_check=true
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_DESTROYED)
        ge1:SetOperation(s.regop)
        Duel.RegisterEffect(ge1,0)
    end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    for tc in aux.Next(eg) do
        for p=0,1 do
            local label=Duel.GetFlagEffectLabel(p,id)
            if not label then label=0 else Duel.ResetFlagEffect(p,id) end
            label=label+1
            Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1,label)
        end
    end
end
function s.spcon(e,c)
    if c==nil then return true end
    return Duel.GetFlagEffectLabel(c:GetControler(),id) and Duel.GetFlagEffectLabel(c:GetControler(),id)>=2 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.thfilter(c,tp)
    return c:IsSetCard(0xc410) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
        and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,nil,c:GetCode())
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local tg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
    if tg:GetCount()>0 then
        Duel.SendtoHand(tg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tg)
        local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,e:GetHandler())
        if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local sg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
            Duel.Destroy(sg,REASON_EFFECT)
        end
    end
end