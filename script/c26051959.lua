-- 新星同盟 三魔官姐妹
-- ID: 26051959
-- 字段: 0x902
local s,id=GetID()
function s.initial_effect(c)
    -- 链接召唤（最稳定方式，杜绝递归）
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x902),2,2)

    -- ① 属性也当作「炎」和「水」
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ADD_ATTRIBUTE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(ATTRIBUTE_FIRE+ATTRIBUTE_WATER)
    c:RegisterEffect(e1)

    -- ② 特殊召唤时检索魔陷（改为加入手卡）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- ③ 其他连接怪兽以外的「新星同盟」卡效果发动时，三选一
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+1000)
    e3:SetCondition(s.opcon)
    e3:SetTarget(s.optg)
    e3:SetOperation(s.opop)
    c:RegisterEffect(e3)
end

-- ② 检索过滤
function s.thfilter(c)
    return c:IsSetCard(0x902) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:IsAbleToHand()
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

-- ③ 条件：其他连接怪兽以外的「新星同盟」卡效果发动
function s.opcon(e,tp,eg,ep,ev,re,r,rp)
    local rc = re:GetHandler()
    -- 排除自身的②效果
    if rc == e:GetHandler() then return false end
    return rc:IsSetCard(0x902) and not rc:IsType(TYPE_LINK)
end

-- ③ 目标：选择1个效果
function s.optg(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1 = Duel.IsPlayerCanDraw(tp,1)
    local b2 = Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    local b3 = Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil)
    if chk==0 then return b1 or b2 or b3 end
    local op = 0
    local ops = {}
    if b1 then ops[#ops+1]=aux.Stringid(id,2000) end
    if b2 then ops[#ops+1]=aux.Stringid(id,3000) end
    if b3 then ops[#ops+1]=aux.Stringid(id,4000) end
    if #ops==1 then
        op = 1
    else
        op = Duel.SelectOption(tp,table.unpack(ops)) + 1
    end
    e:SetLabel(op)
end

-- ③ 操作：执行选中的效果
function s.opop(e,tp,eg,ep,ev,re,r,rp)
    local op = e:GetLabel()
    if op==1 then
        Duel.Draw(tp,1,REASON_EFFECT)
    elseif op==2 then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g = Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    elseif op==3 then
        local g = Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
        if #g>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
            local sg = g:Select(tp,1,1,nil)
            Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        end
    end
end

-- ③ 苏生过滤
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x902) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end