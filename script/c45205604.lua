---战华史略-假献宝刀
--卡密ID: 45205606
--字段代码: 0x0137

local s,id=GetID()

function s.initial_effect(c)
    --永续陷阱发动
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    
    --①效果
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DRAW+CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_SZONE)
    e1:SetHintTiming(0,TIMING_MAIN_END)
    e1:SetCountLimit(1,id+100)
    e1:SetCondition(s.con)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    
    --②效果
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,3))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+200)
    e2:SetCondition(s.retcon)
    e2:SetTarget(s.rettg)
    e2:SetOperation(s.retop)
    c:RegisterEffect(e2)
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end

function s.filter(c)
    return c:IsFaceup() and c:IsSetCard(0x0137) and c:GetLevel()>=6
end

-- ★★★ 修正：costfilter 用 IsAbleToGraveAsCost ★★★
function s.costfilter(c)
    return c:IsSetCard(0x0137) and c:IsAbleToGraveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler())
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
    Duel.SendtoGrave(g,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return true
    end
    -- 检查对方场上有表侧表示的效果怪兽
    local b2 = Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsType(TYPE_EFFECT) end, tp, 0, LOCATION_MZONE, 1, nil)
    
    local opts = {}
    table.insert(opts, {true, aux.Stringid(id,1)})
    if b2 then
        table.insert(opts, {true, aux.Stringid(id,2)})
    end
    
    local op=aux.SelectFromOptions(tp, table.unpack(opts))
    e:SetLabel(op)
    
    if op==1 then
        e:SetCategory(CATEGORY_DRAW)
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
    else
        e:SetCategory(CATEGORY_DISABLE)
        Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,0)
    end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    
    if op==1 then
        Duel.Draw(tp,2,REASON_EFFECT)
    else
        local g=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:IsType(TYPE_EFFECT) end, tp, 0, LOCATION_MZONE, nil)
        if #g==0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local tc=g:Select(tp,1,1,nil):GetFirst()
        if tc then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e2)
        end
    end
end

function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_SZONE)
end

function s.retfilter(c)
    return c:IsSetCard(0x0137) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end

function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.retfilter(chkc) end
    if chk==0 then
        return Duel.IsExistingTarget(s.retfilter,tp,LOCATION_GRAVE,0,1,nil)
            and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g1=Duel.SelectTarget(tp,s.retfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,1,0,0)
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local sg=g:Select(tp,1,1,nil)
        if #sg>0 then
            Duel.Destroy(sg,REASON_EFFECT)
        end
    end
end