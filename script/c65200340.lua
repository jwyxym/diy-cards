local s,id=GetID()

function s.initial_effect(c)
    -- ① 速攻魔法：降攻守、无效并堆墓
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DISABLE+CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    -- ② 墓地除外：特召被送去墓地的仪式怪兽
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.con2)
    e2:SetCost(s.cost2)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
end

-- ① 目标：以场上1只怪兽为对象
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end

-- ① 处理
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end

    -- 获取自己场上攻击力最高的怪兽的数值
    local max_atk=0
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    for sc in aux.Next(g) do
        if sc:GetAttack()>max_atk then
            max_atk=sc:GetAttack()
        end
    end
    if max_atk<=0 then return end

    -- 降攻守
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(-max_atk)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    tc:RegisterEffect(e2)

    -- 判断是否因此变为0
    local current_atk = tc:GetAttack()
    local current_def = tc:GetDefense()
    
    -- 如果属性为0（受效果影响后，引擎自动将低于0的数值截断为0）
    if current_atk == 0 or current_def == 0 then
        -- 无效效果
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_DISABLE)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e3)
        local e4=e3:Clone()
        e4:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(e4)

        -- 卡组送墓1只不死族
        if Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_DECK,0,1,nil,RACE_ZOMBIE) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local dg=Duel.SelectMatchingCard(tp,Card.IsRace,tp,LOCATION_DECK,0,1,1,nil,RACE_ZOMBIE)
            if #dg>0 then
                Duel.SendtoGrave(dg,REASON_EFFECT)
            end
        end
    end
end

-- ② 条件：不死族仪式怪兽被送去墓地
function s.con2(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.filter2,1,nil,tp)
end
function s.filter2(c,tp)
    return c:IsControler(tp) and c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_RITUAL)
        and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end

-- ② Cost：除外自身
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToRemove() end
    Duel.Remove(c,POS_FACEUP,REASON_COST)
end

-- ② 目标
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end

-- ② 处理
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.filter2,nil,tp)
    if g:GetCount()==0 then return end
    local tc=g:GetFirst()
    if tc and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        -- 是魔神则回复1000LP
        if tc:IsCode(65200270) then
            Duel.Recover(tp,1000,REASON_EFFECT)
        end
    end
end