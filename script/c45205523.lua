--山铜结界之气
--卡密ID: 45205523

local s,id=GetID()

function s.initial_effect(c)
    --③效果：卡组·场上·墓地当作「山铜结界」使用
    aux.EnableChangeCode(c,48179391,LOCATION_DECK+LOCATION_ONFIELD+LOCATION_GRAVE)

    --④效果：场上只能有1张表侧表示存在（手动限制发动）
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCondition(s.actcon)  -- 添加发动条件
    c:RegisterEffect(e0)

    --①效果：战斗伤害步骤开始时，从卡组送墓1张有「山铜结界」记述的卡，破坏对方1只怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_BATTLE_START)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id+100)
    e1:SetCondition(s.descon)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    --②效果：结束阶段，回复场上卡的数量×500的基本分（精确计算版）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id+200)
    e2:SetOperation(s.revop)
    c:RegisterEffect(e2)
end

-- 发动条件：自己场上没有另一张表侧的此卡
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return not Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_SZONE, 0, 1, c, id)
end

--①效果条件：对方怪兽进行战斗
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    if not a or not d then return false end
    return (a:GetControler()==tp and d:GetControler()==1-tp) or (d:GetControler()==tp and a:GetControler()==1-tp)
end

function s.costfilter(c)
    if not c or not c.IsCode then return false end
    return c:IsAbleToGrave() and (c:IsCode(48179391) or aux.IsCodeOrListed(c,48179391))
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil)
            and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_EFFECT)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local tg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetTargetCard(tg)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end

--②效果：精确回复基本分
function s.revop(e,tp,eg,ep,ev,re,r,rp)
    local ct=0
    -- 自己
    ct = ct + Duel.GetFieldGroupCount(tp, 0, LOCATION_MZONE)
    ct = ct + Duel.GetFieldGroupCount(tp, 0, LOCATION_SZONE)
    if Duel.GetFieldCard(tp, LOCATION_FZONE, 0) then ct = ct + 1 end
    -- 对方
    ct = ct + Duel.GetFieldGroupCount(1-tp, 0, LOCATION_MZONE)
    ct = ct + Duel.GetFieldGroupCount(1-tp, 0, LOCATION_SZONE)
    if Duel.GetFieldCard(1-tp, LOCATION_FZONE, 0) then ct = ct + 1 end

    local val = ct * 500
    Duel.Recover(tp, val, REASON_EFFECT)
end