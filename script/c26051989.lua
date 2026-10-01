-- 逆时残响 星锑
-- ID: 26051989
-- 字段：逆时残响 0x910
local s,id=GetID()
function s.initial_effect(c)
    aux.EnablePendulumAttribute(c)
    -- 灵摆效果：墓地·除外的4张本家回卡组抽1
    local pe1=Effect.CreateEffect(c)
    pe1:SetDescription(aux.Stringid(id,0))
    pe1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    pe1:SetType(EFFECT_TYPE_IGNITION)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCountLimit(1,id)
    pe1:SetTarget(s.pentg)
    pe1:SetOperation(s.penop)
    c:RegisterEffect(pe1)

    -- 怪兽①：召唤·特召检索本家灵摆怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id+1000)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    -- 怪兽②：破坏本家灵摆，回收额外表侧本家灵摆
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+2000)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)

    -- 怪兽③：最多2只魔法师等级变4
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetCategory(CATEGORY_LVCHANGE)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id+3000)
    e4:SetTarget(s.lvtg)
    e4:SetOperation(s.lvop)
    c:RegisterEffect(e4)
end

-- 灵摆效果
function s.penfilter(c)
    return c:IsSetCard(0x910) and c:IsAbleToDeck()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,4,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,4,tp,LOCATION_GRAVE+LOCATION_REMOVED)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,4,4,nil)
    if #g==4 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end

-- 怪兽① 检索
function s.thfilter(c)
    return c:IsSetCard(0x910) and c:IsType(TYPE_PENDULUM) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
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

-- 怪兽② 破坏+回收
function s.dfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x910) and c:IsType(TYPE_PENDULUM)
end
function s.recfilter(c)
    return c:IsSetCard(0x910) and c:IsType(TYPE_PENDULUM) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.dfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.dfilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(s.recfilter,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.dfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
        local g=Duel.GetMatchingGroup(s.recfilter,tp,LOCATION_EXTRA,0,nil)
        if #g>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local sg=g:Select(tp,1,1,nil)
            Duel.SendtoHand(sg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sg)
        end
    end
end

-- 怪兽③ 等级变4
function s.lvfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(1)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lvfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,2,nil)
    Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,g,g:GetCount(),0,0)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if not tg then return end
    local tc=tg:GetFirst()
    while tc do
        if tc:IsRelateToEffect(e) and tc:IsFaceup() then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_LEVEL)
            e1:SetValue(4)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
        end
        tc=tg:GetNext()
    end
end