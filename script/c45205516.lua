--哥布林陷阱卡 (45205516)
--字段代码: 0xAC (哥布林)

local s,id=GetID()

function s.initial_effect(c)
    -- 规则上也当作「哥布林」卡使用
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetValue(0xAC)
    c:RegisterEffect(e0)
    
    --①效果：对方发动效果时，场上有8星以上哥布林怪兽，那个效果无效，选自己场上·墓地的1张卡除外
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
    
    --②效果：墓地除外哥布林怪兽，盖放自身
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_LEAVE_GRAVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+100)
    e2:SetCost(s.setcost)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end

--①效果条件（参考竜星の九支）
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    -- ★★★ 自己场上有8星以上的「哥布林」怪兽 ★★★
    local g=Duel.GetMatchingGroup(s.goblinfilter,tp,LOCATION_MZONE,0,nil)
    if #g==0 then return false end
    -- ★★★ 对方发动怪兽·魔法·陷阱效果 ★★★
    return re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end

function s.goblinfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xAC) and c:IsLevelAbove(8)
end

--①效果目标
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- ★★★ 检查自己场上·墓地是否有卡可以除外 ★★★
        return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end

--①效果处理（参考竜星の九支）
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    -- ★★★ 无效那个效果 ★★★
    if Duel.NegateEffect(ev) then
        -- ★★★ 选自己场上·墓地的1张卡除外 ★★★
        local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
        if #g>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local sg=g:Select(tp,1,1,nil)
            if #sg>0 then
                Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
            end
        end
    end
end

--②效果cost
function s.setcostfilter(c)
    return c:IsSetCard(0xAC) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end

function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.setcostfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.setcostfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end

--②效果目标
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return c:IsLocation(LOCATION_GRAVE)
            and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
    end
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end

--②效果处理
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if not c:IsLocation(LOCATION_GRAVE) then return end
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    
    Duel.SSet(tp,c)
    
    -- 从场上离开时除外
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetValue(LOCATION_REMOVED)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e1)
end