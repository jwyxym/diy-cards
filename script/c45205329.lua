--迷雾之都 L-D (45205329)
--字段代码: 0x1D5C (侦探)

local s,id=GetID()

function s.initial_effect(c)
    --①效果：发动时从卡组把1张「侦探」魔法卡加入手卡（无引擎弹窗）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    
    --②效果：自己场上有「侦探」融合怪兽时，从卡组·额外卡组把1只「侦探」怪兽送去墓地
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.gvcon)
    e2:SetTarget(s.gvtg)
    e2:SetOperation(s.gvop)
    c:RegisterEffect(e2)
end

--①效果：从卡组把1张「侦探」魔法卡加入手卡
function s.thfilter(c)
    return c:IsSetCard(0x1D5C) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    -- ★★★ 只保留这一个弹窗 ★★★
    if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end

--②效果条件：自己场上有「侦探」融合怪兽
function s.gvcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.fufilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.fufilter(c)
    return c:IsFaceup() and c:IsSetCard(0x1D5C) and c:IsType(TYPE_FUSION)
end

--②效果目标：从卡组·额外卡组把1只「侦探」怪兽送去墓地
function s.gvfilter(c)
    return c:IsSetCard(0x1D5C) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end

function s.gvtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.gvfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end

function s.gvop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.gvfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end