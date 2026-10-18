--姬装战线·出动
--字段：姬装战线（0xFA1）

local s,id,o=GetID()
local SET_JI_ZHUANG=0xFA1

function s.initial_effect(c)
    --①：从卡组把1只「姬装战线」怪兽加入手卡。对方场上有怪兽存在的场合，可以再从自己的卡组·墓地选1只「姬装战线」怪兽盖放。
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
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
    e2:SetTarget(s.thtg2)
    e2:SetOperation(s.thop2)
    c:RegisterEffect(e2)
end

function s.thfilter(c)
    return c:IsSetCard(SET_JI_ZHUANG) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.setfilter(c)
    return c:IsSetCard(SET_JI_ZHUANG) and c:IsType(TYPE_MONSTER)
        and c:IsSSetable()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    --从卡组加入手卡
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOH_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g==0 then return end
    Duel.SendtoHand(g,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)
    
    --那之后，对方场上有怪兽的场合，可以盖放
    if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0 then return end
    local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
    if #sg==0 then return end
    if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
    
    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local setg=sg:Select(tp,1,1,nil)
    if #setg>0 then
        Duel.SSet(tp,setg:GetFirst())
    end
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_SZONE)
        and c:IsPreviousPosition(POS_FACEDOWN)
        and c:IsPreviousControler(tp)
        and c:IsReason(REASON_EFFECT)
end

function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end

function s.thop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
    end
end
