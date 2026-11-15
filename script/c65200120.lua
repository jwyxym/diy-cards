local s,id=GetID()
local id_toki=65200090

function s.initial_effect(c)
    aux.AddCodeList(c, id_toki)

    -- ① 检索 + 加防
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DEFCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- ② 被除外回收
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SSET)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_REMOVE)
    e2:SetCountLimit(1,id+1)
    e2:SetTarget(s.remtg)
    e2:SetOperation(s.remop)
    c:RegisterEffect(e2)
end

-- ① 检索过滤器
function s.thfilter(c)
    return (c:IsCode(id_toki) or aux.IsCodeListed(c, id_toki)) and not c:IsCode(id) and c:IsAbleToHand()
end

-- ① 目标判定
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- ① 效果处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        
        -- 检索完之后判定场上是否有记述怪兽
        local has_toki = Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and (c:IsCode(id_toki) or aux.IsCodeListed(c, id_toki)) end,tp,LOCATION_ONFIELD,0,1,nil)
        if has_toki then
            local tg=Duel.GetMatchingGroup(aux.FilterBoolFunction(Card.IsFaceup,RACE_ZOMBIE),tp,LOCATION_MZONE,0,nil)
            for tc in aux.Next(tg) do
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_DEFENSE)
                e1:SetValue(500)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                tc:RegisterEffect(e1)
            end
        end
    end
end

-- ② 回收判定
function s.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToHand() or c:IsSSetable() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end

-- ② 回收处理
function s.remop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if c:IsAbleToHand() and (not c:IsSSetable() or Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))==0) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,c)
    else
        Duel.SSet(tp,c)
    end
end