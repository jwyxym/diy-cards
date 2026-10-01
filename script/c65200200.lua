local s,id=GetID()
local NM=0x32a

if not _G.NM_RELEASE_REG then
    _G.NM_RELEASE_REG = true
    local ge=Effect.GlobalEffect()
    ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge:SetCode(EVENT_RELEASE)
    ge:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        for tc in aux.Next(eg) do
            local owner=tc:GetPreviousControler()
            if owner and tc:IsRace(RACE_ZOMBIE) then
                Duel.RegisterFlagEffect(owner, 65200200, RESET_DUEL, 0, 1)
            end
        end
    end)
    Duel.RegisterEffect(ge, 0)
end

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id+1)
    e3:SetCondition(s.con2)
    e3:SetTarget(s.tg2)
    e3:SetOperation(s.op2)
    c:RegisterEffect(e3)
end

function s.thfilter(c)
    return c:IsSetCard(NM) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
    if Duel.GetFlagEffect(tp, id) >= 10 then
        if Duel.SelectYesNo(tp, aux.Stringid(id,2)) then
            local c=e:GetHandler()
            local g1=Duel.GetMatchingGroup(nil, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
            local g2=Duel.GetMatchingGroup(nil, 1-tp, LOCATION_MZONE, LOCATION_MZONE, nil)
            g1:Merge(g2)
            g1:RemoveCard(c)
            if #g1>0 then
                Duel.HintSelection(g1)
                Duel.Destroy(g1, REASON_EFFECT)
            end
        end
    end
end

function s.con2(e,tp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,nil)
        and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,PLAYER_ALL,LOCATION_GRAVE+LOCATION_ONFIELD)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g1=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g1==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g2=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    if #g2==0 then return end
    g1:Merge(g2)
    Duel.HintSelection(g1)
    Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)
end