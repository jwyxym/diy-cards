-- 卡名：肃归之戈
-- 卡密：12210004
-- 衍生物卡密：12210005
local s,id=GetID()
function s.initial_effect(c)
    --① 封锁对方墓地特召+墓地发动效果
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0,1)
    e1:SetTarget(s.splimit)
    c:RegisterEffect(e1)
    
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,1)
    e2:SetValue(s.aclimit)
    c:RegisterEffect(e2)

    --② 1回合1次生成灵体衍生物
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(12210004,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.tktg)
    e3:SetOperation(s.tkop)
    c:RegisterEffect(e3)

    --③ 战斗时送墓守备2000以下怪兽
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(12210004,1))
    e4:SetCategory(CATEGORY_TOGRAVE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)  e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e4:SetCondition(s.tgcon)
    e4:SetTarget(s.tgtg)
    e4:SetOperation(s.tgop)
    c:RegisterEffect(e4)
end

--① 墓地特召限制
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return c:IsLocation(LOCATION_GRAVE)
end

--① 墓地效果发动限制
function s.aclimit(e,re,tp)
    return re:GetHandler():IsLocation(LOCATION_GRAVE)
end

--② 衍生物召唤目标
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) end
    if chk==0 then return Duel.IsExistingTarget(Card.IsMonster,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,12210005,0,TYPES_TOKEN,0,0,1,RACE_ZOMBIE,ATTRIBUTE_DARK) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,Card.IsMonster,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

--② 衍生物召唤操作
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,12210005,0,TYPES_TOKEN,0,0,1,RACE_ZOMBIE,ATTRIBUTE_DARK) then return end
    local token=Duel.CreateToken(tp,12210005)
    Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
    if tc:IsRelateToEffect(e) then
        local atk=tc:GetBaseAttack()
        local def=tc:GetBaseDefense()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(atk)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        token:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
        e2:SetValue(def)
        token:RegisterEffect(e2)
    end
    Duel.SpecialSummonComplete()
end

--③ 战斗送墓条件
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    return bc and bc:IsDefenseBelow(2000)
end

--③ 战斗送墓目标
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local bc=e:GetHandler():GetBattleTarget()
    if chk==0 then return bc:IsAbleToGrave() end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,bc,1,0,0)
end

--③ 战斗送墓操作
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    if bc:IsRelateToBattle() then
        Duel.SendtoGrave(bc,REASON_EFFECT)
    end
end
