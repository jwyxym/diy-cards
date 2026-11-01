-- Sumimi的歌姬 纯田真奈
-- ID: 15040032
-- 5星 光属性 天使族
-- 「Sumimi的吉他手 三角初华」：15040034
local s,id=GetID()
function s.initial_effect(c)
    -- ① 这张卡可以不用解放做召唤（无条件）
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_SUMMON_PROC)
    e0:SetCondition(s.ntcon)
    c:RegisterEffect(e0)

    -- ② 召唤·特殊召唤成功时，丢弃1张手卡，从卡组·墓地取「Sumimi的吉他手 三角初华」
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    -- ③ 在除外状态，自己场上有5星天使族或5星幻想魔族怪兽特殊召唤时，加入手卡
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_REMOVED)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id+1)
    e3:SetCondition(s.retcon)
    e3:SetTarget(s.rettg)
    e3:SetOperation(s.retop)
    c:RegisterEffect(e3)
end

-- ① 无解放召唤条件：minc==0 时允许无解放召唤
function s.ntcon(e,c,minc)
    if c==nil then return true end
    return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end

-- ② cost：丢弃1张手卡
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

-- ② 检索对象：「Sumimi的吉他手 三角初华」(15040034)
function s.thfilter(c)
    return c:IsCode(15040034) and c:IsAbleToHand()
end
-- 用于判断自己场上是否存在「Sumimi的吉他手 三角初华」
function s.partnerfilter(c)
    return c:IsFaceup() and c:IsCode(15040034)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local can_th=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
        local has_partner=Duel.IsExistingMatchingCard(s.partnerfilter,tp,LOCATION_ONFIELD,0,1,nil)
        local can_draw=has_partner and Duel.IsPlayerCanDraw(tp,1)
        return can_th or can_draw
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

-- ② 操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local has_partner=Duel.IsExistingMatchingCard(s.partnerfilter,tp,LOCATION_ONFIELD,0,1,nil)
    local can_th=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)

    if has_partner and Duel.IsPlayerCanDraw(tp,1) then
        -- 场上有「Sumimi的吉他手 三角初华」时，可作为代替抽1张
        local use_draw=false
        if can_th then
            use_draw = Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))==1
        else
            use_draw = true
        end
        if use_draw then
            Duel.Draw(tp,1,REASON_EFFECT)
            return
        end
    end

    if can_th then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end

-- ③ 条件：自己场上有5星天使族或5星幻想魔族怪兽特殊召唤成功
function s.retfilter(c,tp)
    return c:IsControler(tp) and c:IsLevel(5)
        and (c:IsRace(RACE_FAIRY) or c:IsRace(RACE_ILLUSION or 0x2000000))
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.retfilter,1,nil,tp)
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_REMOVED) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
    end
end