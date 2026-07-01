-- 极星天 美奂之凡娜迪丝
local s,id=GetID()
function s.initial_effect(c)
    --①效果：送墓卡组极星怪兽，改变等级
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.lvcost)
    e1:SetOperation(s.lvop)
    c:RegisterEffect(e1)
    
    --②效果：作为同调素材送墓时，回收墓地的极星怪兽
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

--①效果cost：从卡组把等级不同的1只极星怪兽送去墓地
function s.costfilter(c,lv)
    return c:IsSetCard(0x42) and c:IsLevelAbove(1) and not c:IsLevel(lv) and c:IsAbleToGraveAsCost()
end
function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel())
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil,c:GetLevel())
    e:SetLabel(g:GetFirst():GetLevel())
    Duel.SendtoGrave(g,REASON_COST)
end

--①效果处理：等级变成和送去墓地的怪兽相同
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local lv=e:GetLabel()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_LEVEL)
        e1:SetValue(lv)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end

--②效果条件：作为同调素材送去墓地
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end

--②效果过滤：极星天美奂之凡娜迪丝以外的极星怪兽
function s.thfilter(c)
    return c:IsSetCard(0x42) and not c:IsCode(14151807) and c:IsAbleToHand()
end

--②效果目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

--②效果处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end