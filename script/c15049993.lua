-- 無休止的噩夢
-- ID: 15040029
-- 速攻魔法
-- 「千早爱音」字段：0xb12
local s,id=GetID()
function s.initial_effect(c)
    -- ① 卡的发动
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.actcon)
    e1:SetTarget(s.acttg)
    e1:SetOperation(s.actop)
    c:RegisterEffect(e1)

    -- ② 墓地回收
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.retcon)
    e2:SetCost(s.retcost)
    e2:SetTarget(s.rettg)
    e2:SetOperation(s.retop)
    c:RegisterEffect(e2)
end

-- ① 发动条件：自己场上有「千早爱音」怪兽或「长崎爽世」怪兽
function s.fieldfilter(c)
    return c:IsFaceup() and (c:IsSetCard(0xb12) or c:IsSetCard(0xb14))
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- ① 特殊召唤对象：自己墓地·除外状态的「千早爱音」怪兽
function s.spfilter(c,e,tp)
    return c:IsSetCard(0xb12) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

-- ① 操作
function s.actop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
    if #g==0 then return end
    if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    -- 先检查是否存在可同调 / 连接召唤的目标；两者都没有则直接结束（不显示支付LP选项）
    local b1=Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,tp)
    local b2=Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_EXTRA,0,1,nil,tp)
    if not (b1 or b2) then return end

    -- 可以支付一半基本分
    if Duel.CheckLPCost(tp,math.ceil(Duel.GetLP(tp)/2)) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.PayLPCost(tp,math.ceil(Duel.GetLP(tp)/2))

        local ops={}
        local opval={}
        if b1 then
            ops[#ops+1]=aux.Stringid(id,3)
            opval[#opval+1]=1
        end
        if b2 then
            ops[#ops+1]=aux.Stringid(id,4)
            opval[#opval+1]=2
        end
        if #ops==0 then return end
        local sel=opval[Duel.SelectOption(tp,table.unpack(ops))+1]

        if sel==1 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
            local sc=sg:GetFirst()
            if sc then
                Duel.SynchroSummon(tp,sc,nil)
            end
        elseif sel==2 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg=Duel.SelectMatchingCard(tp,s.linkfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
            local sc=sg:GetFirst()
            if sc then
                Duel.LinkSummon(tp,sc,nil)
            end
        end
    end
end

-- 「千早爱音」怪兽过滤（用于确认场上存在）
function s.kirbyfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xb12) and c:IsType(TYPE_MONSTER)
end

-- 可同调召唤的天使族同调怪兽：场上需有「千早爱音」怪兽，且当前可以同调召唤
function s.synfilter(c,tp)
    if not (c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_FAIRY)) then return false end
    if not c:IsSynchroSummonable(nil) then return false end
    return Duel.IsExistingMatchingCard(s.kirbyfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- 可连接召唤的天使族连接怪兽：场上需有「千早爱音」怪兽，且当前可以连接召唤
function s.linkfilter(c,tp)
    if not (c:IsType(TYPE_LINK) and c:IsRace(RACE_FAIRY)) then return false end
    if not c:IsLinkSummonable(nil) then return false end
    return Duel.IsExistingMatchingCard(s.kirbyfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- ② 条件：自己场上的「千早爱音」怪兽因对方的效果从场上离开
function s.retfilter(c,tp)
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
        and c:IsSetCard(0xb12) and c:IsType(TYPE_MONSTER)
        and c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.retfilter,1,nil,tp)
end

-- ② cost：丢弃1张手卡
function s.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

-- ② 目标
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end

-- ② 操作
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_GRAVE) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
    end
end