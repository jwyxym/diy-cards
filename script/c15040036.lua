-- 金玉良缘 sumimi!
-- ID: 15040036
-- 光属性 / 天使族 / 超量 / 5阶
-- 天使族·光属性5星怪兽×2
-- 「Sumimi的歌姬 纯田真奈」：15040032
-- 「Sumimi的吉他手 三角初华」：15040034
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- 超量召唤：天使族·光属性5星怪兽×2
    aux.AddXyzProcedure(c, s.xyzfilter, 5, 2)

    -- ② 1回合1次，取除2个X素材，从卡组把1只可通常召唤的5~6星天使族·光属性怪兽加入手卡
    -- ① 没有指定两张卡之一作为X素材的这张卡不能把效果发动（在条件中检查）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.thcon)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
end

-- 超量素材条件：天使族·光属性5星怪兽
function s.xyzfilter(c)
    return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(5)
end

-- ① 条件：X素材中必须有「Sumimi的歌姬 纯田真奈」(15040032) 或「Sumimi的吉他手 三角初华」(15040034)
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsType(TYPE_XYZ) then return false end
    local mg=c:GetOverlayGroup()
    if not mg then return false end
    return mg:IsExists(Card.IsCode,1,nil,15040032) or mg:IsExists(Card.IsCode,1,nil,15040034)
end

-- ② cost：取除2个X素材
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:CheckRemoveOverlayCard(tp,2,REASON_COST) end
    c:RemoveOverlayCard(tp,2,2,REASON_COST)
end

-- ② 检索对象：可以通常召唤的5~6星天使族·光属性怪兽
function s.thfilter(c)
    return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)
        and c:IsLevelAbove(5) and c:IsLevelBelow(6)
        and c:IsSummonable(true,nil)
        and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- ② 操作：加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end