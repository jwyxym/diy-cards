--姬装战线·遏制
--字段：姬装战线（0xFA1）

local s,id,o=GetID()
local SET_JI_ZHUANG=0xFA1

function s.initial_effect(c)
    --①：以自己场上1只「姬装战线」怪兽和对方场上1张卡为对象才能发动。那些卡破坏。那之后，自己墓地有「姬装战线」同调怪兽存在的场合，可以选对方场上1张表侧表示的卡，那个效果直到回合结束时无效。
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
    
    --②：盖放的这张卡被效果破坏的场合才能发动。这张卡加入手卡。
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+o)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

function s.desfilter1(c)
    return c:IsSetCard(SET_JI_ZHUANG) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then
        return Duel.IsExistingTarget(s.desfilter1,tp,LOCATION_MZONE,0,1,nil)
            and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g1=Duel.SelectTarget(tp,s.desfilter1,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
    g1:Merge(g2)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.synfilter(c)
    return c:IsSetCard(SET_JI_ZHUANG) and c:IsType(TYPE_SYNCHRO)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if not tg then return end
    local dg=tg:Filter(Card.IsRelateToEffect,nil,e)
    if #dg==0 then return end
    
    if Duel.Destroy(dg,REASON_EFFECT)==0 then return end
    
    --那之后，墓地有姬装战线同调怪兽的场合，可以无效对方1张表侧卡
    if not Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_GRAVE,0,1,nil) then return end
    if not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) then return end
    if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
    
    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
    local sg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
    if #sg==0 then return end
    
    local tc=sg:GetFirst()
    --无效效果（直到回合结束时）
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_DISABLE_EFFECT)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e2)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_SZONE) 
        and c:IsPreviousPosition(POS_FACEDOWN)
        and c:IsPreviousControler(tp)
        and c:IsReason(REASON_EFFECT)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
    end
end
