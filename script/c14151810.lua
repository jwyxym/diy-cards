--极星宝 永恒之枪
function c14151810.initial_effect(c)
    -- ①效果：效果处理时除外自身，破坏对方1张卡和自己1只极神
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(14151810,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,14151810)
    e1:SetTarget(c14151810.target)
    e1:SetOperation(c14151810.operation)
    c:RegisterEffect(e1)

    -- ②效果：只要在除外区，回合结束阶段盖放回场上
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(14151810,1))
    e2:SetCategory(CATEGORY_LEAVE_GRAVE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetRange(LOCATION_REMOVED)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,14151811)
    e2:SetCondition(c14151810.spcon)
    e2:SetTarget(c14151810.sptg)
    e2:SetOperation(c14151810.spop)
    c:RegisterEffect(e2)
end

--①效果目标：自己场上1只「极神」怪兽 + 对方场上1张卡
function c14151810.filter_self(c)
    return c:IsFaceup() and c:IsSetCard(0x4b) and c:IsType(TYPE_MONSTER)
end

function c14151810.filter_opp(c)
    return true
end

function c14151810.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        if chkc:IsControler(1-tp) then
            return c14151810.filter_opp(chkc)
        else
            return c14151810.filter_self(chkc)
        end
    end
    if chk==0 then
        return Duel.IsExistingTarget(c14151810.filter_self,tp,LOCATION_MZONE,0,1,nil)
            and Duel.IsExistingTarget(c14151810.filter_opp,tp,0,LOCATION_ONFIELD,1,nil)
            and e:GetHandler():IsAbleToRemove()
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g1=Duel.SelectTarget(tp,c14151810.filter_self,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g2=Duel.SelectTarget(tp,c14151810.filter_opp,tp,0,LOCATION_ONFIELD,1,1,nil)
    g1:Merge(g2)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end

function c14151810.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- 除外自身
    if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_SZONE) then
        Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
    end
    
    -- 破坏对象
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    local tg=g:Filter(Card.IsRelateToEffect,nil,e)
    if #tg>0 then
        Duel.Destroy(tg,REASON_EFFECT)
    end
end

--②效果条件：只要在除外区
function c14151810.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsLocation(LOCATION_REMOVED)
end

--②效果目标
function c14151810.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and c:IsLocation(LOCATION_REMOVED)
            and c:IsSSetable()
    end
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end

--②效果处理：从除外区盖放
function c14151810.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if not c:IsLocation(LOCATION_REMOVED) then return end
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    
    -- ★★★ 只改了这里：加了个 c:IsSSetable() 判断 ★★★
    if c:IsSSetable() then
        Duel.SSet(tp,c)
    end
end