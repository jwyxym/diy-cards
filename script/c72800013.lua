-- Ebizuka Tomo
-- ID: 72800013
-- 光属性 / 爬虫类族 / 5星 / ATK 1600 / DEF 1480
-- 「TOGENASHI TOGEARI」字段：0xb15
local s,id=GetID()
function s.initial_effect(c)
    -- ① 自己场上有「TOGENASHI TOGEARI」卡时，从手卡特殊召唤，之后可以抽1张
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- ② 不会被战斗破坏
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- ③-1 一速起动效果（自己场上怪兽属性不足3种时，自己主要阶段）
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+1)
    e3:SetCondition(aux.NOT(s.attrcon))
    e3:SetTarget(s.rmtg)
    e3:SetOperation(s.rmop)
    c:RegisterEffect(e3)

    -- ③-2 二速（自己场上怪兽属性3种以上时，双方回合均可发动）
    local e4=e3:Clone()
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e4:SetCondition(s.attrcon)
    c:RegisterEffect(e4)
end

-- ① 条件：自己场上有「TOGENASHI TOGEARI」卡
function s.fieldfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xb15)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        if Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.BreakEffect()
            Duel.Draw(tp,1,REASON_EFFECT)
        end
    end
end

-- ③ 条件判断：自己场上表侧怪兽的属性达到3种以上
function s.attrcon(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    local attrs={}
    local cnt=0
    local tc=g:GetFirst()
    while tc do
        local a=tc:GetAttribute()
        if a and a>0 and not attrs[a] then
            attrs[a]=true
            cnt=cnt+1
        end
        tc=g:GetNext()
    end
    return cnt>=3
end

-- ③ 目标：对方墓地最多3张可除外的卡
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
    local ct=math.min(3,g:GetCount())
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,ct,0,0)
end
-- ③ 操作：除外对方墓地最多3张卡（允许选择1~3张）
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
    if #g==0 then return end
    local ct=math.min(3,#g)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local sg=g:Select(tp,1,ct,nil)
    if #sg>0 then
        Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
    end
end