-- 大家一起喝下午茶 宇田川亚子
-- ID: 44821010
-- 记述「Roselia」(44821000)
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,44821000)          -- 此卡记述「Roselia」
    aux.AddMaterialCodeList(c,44821004)  -- 融合素材包含「小小的魔王 宇田川亚子」

    -- 融合召唤：「小小的魔王 宇田川亚子」+ 植物族·暗属性怪兽
    c:EnableReviveLimit()
    aux.AddFusionProcFun2(c,
        aux.FilterBoolFunction(Card.IsCode,44821004),
        function(fc) return fc:IsRace(RACE_PLANT) and fc:IsAttribute(ATTRIBUTE_DARK) and fc:IsType(TYPE_MONSTER) end,
        true)

    -- ① 融合召唤成功时，从卡组把1张记述「Roselia」的卡加入手卡
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.thcon)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- ② 同1次战斗阶段中可以攻击2次
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EXTRA_ATTACK)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- ③ 自己主要阶段，解放1只怪兽，从手卡·卡组特召1只记述「Roselia」的怪兽
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+1000)
    e3:SetTarget(s.reltg)
    e3:SetOperation(s.relop)
    c:RegisterEffect(e3)
end

-- ① 条件：融合召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- ① 检索对象：记述「Roselia」的卡
function s.thfilter(c)
    return aux.IsCodeListed(c,44821000) and c:IsAbleToHand()
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

-- ③ 可解放的怪兽：默认自己场上；若场上有「Roselia」，可包含对方场上
function s.relfilter(c,tp,has_roselia)
    if not c:IsType(TYPE_MONSTER) then return false end
    if c:IsControler(tp) then return true end
    return has_roselia
end

-- ③ 可特召对象：记述「Roselia」的怪兽
function s.spfilter(c,e,tp)
    return aux.IsCodeListed(c,44821000) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ③ 目标
function s.reltg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local has_roselia=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,44821000)
        local self_ok=Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_MONSTER)
        local opp_ok=has_roselia and Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_MZONE,1,nil,TYPE_MONSTER)
        local can_sp=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
        return can_sp and (self_ok or opp_ok)
    end
    Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,0,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

-- ③ 操作
function s.relop(e,tp,eg,ep,ev,re,r,rp)
    local has_roselia=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,44821000)
    -- 选择要解放的怪兽（自己场上或对方场上）
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_MONSTER)
    g=g:Filter(function(c) return c:IsReleasable() end,nil)
    if not has_roselia then
        g=g:Filter(Card.IsControler,nil,tp)
    end
    if #g==0 then return end
    local rg=g:Select(tp,1,1,nil)
    if #rg==0 then return end
    Duel.Release(rg,REASON_EFFECT)

    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
    if #sg>0 then
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end
end