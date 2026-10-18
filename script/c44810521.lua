--誓约的精灵 希欧娜·埃德尔
local s,id=GetID()
function s.initial_effect(c)
    --① 让这张卡从手卡回到卡组才能发动，从卡组把1张「无闻的勇者 纳格迩·钴格」加入手卡
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    --② 召唤·特殊召唤成功时，抽2张，然后将1张手卡放回卡组
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.drcon)
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    c:RegisterEffect(e2)
    local e2b=e2:Clone()
    e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2b)

    --③ 1回合最多3次，「无闻的勇者」的效果处理完毕后另开连锁发动
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_CHAIN_SOLVED)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(3,id+2)
    e3:SetCondition(s.descon)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)
end

--① cost：将这张卡从手卡回到卡组
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
    Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.thfilter(c)
    return c:IsCode(44810520) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

--②条件
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(function(c)
        return c:IsCode(44810520) and c:IsFaceup()
    end,tp,LOCATION_MZONE,0,1,nil)
    and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsExistingMatchingCard(function(c)
        return c:IsCode(44810520) and c:IsFaceup()
    end,tp,LOCATION_MZONE,0,1,nil) then return end
    if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0 then return end
    if Duel.Draw(tp,2,REASON_EFFECT)==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end

--③条件：刚解决的连锁效果来自「无闻的勇者 纳格迩·钴格」(放宽判定)
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    if not re then return false end
    local rc=re:GetHandler()
    if not rc then return false end
    return rc:IsCode(44810520)
end

--③目标
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsCode(44810520) end
    if chk==0 then
        local g=Duel.GetMatchingGroup(function(c)
            return c:IsCode(44810520) and c:IsFaceup()
        end,tp,LOCATION_MZONE,0,nil)
        if #g==0 then return false end
        local og=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
        if #og==0 then return false end
        local tc=g:GetFirst()
        while tc do
            local attr=tc:GetAttribute()
            if og:IsExists(function(c) return c:GetAttribute()==attr end,1,nil) then
                return true
            end
            tc=g:GetNext()
        end
        return false
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,function(c)
        return c:IsCode(44810520) and c:IsFaceup()
    end,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end

--③操作
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local attr=tc:GetAttribute()
    local dg=Duel.GetMatchingGroup(function(c)
        return c:IsFaceup() and c:GetAttribute()==attr
    end,tp,0,LOCATION_MZONE,nil)
    if #dg>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local sg=dg:Select(tp,1,1,nil)
        Duel.Destroy(sg,REASON_EFFECT)
    end
    local ag=Duel.GetMatchingGroup(function(c)
        return c:IsCode(44810520) and c:IsFaceup()
    end,tp,LOCATION_MZONE,0,nil)
    local ac=ag:GetFirst()
    while ac do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(200)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        ac:RegisterEffect(e1)
        ac=ag:GetNext()
    end
end

