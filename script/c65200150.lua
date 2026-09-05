-- 《<梦魇>骸骨驯兽师》
-- 卡号：65200150
-- 属性：暗 种族：不死族 等级：7 攻击：1500 守备：2000
local s,id=GetID()
local NM=0x32a
local TOKEN_SKULL=65200900
local TOKEN_ZOMBIE=65200901

function s.initial_effect(c)
    -- ① 解放自己场上1只怪兽才能发动。这张卡从手卡·墓地特殊召唤。
    --    那之后在自己场上将各最多1只「骷髅士兵衍生物」「僵尸衍生物」特殊召唤。
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- ② 自己把衍生物特殊召唤的回合，那些怪兽可以直接攻击（在①中处理）

    -- ③ 将墓地的这张卡除外才能发动。从卡组将同名卡不在自己墓地存在的1张「<梦魇>」卡加入手卡。
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+100)
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

-- ① Cost：解放自己场上1只怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
    local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
    Duel.Release(g,REASON_COST)
end

-- ① Target：确认自身可特召
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

-- ① Operation：特召自身 + 生成衍生物（衍生物获得直击能力）
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    -- 特召自身
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    -- 生成骷髅士兵衍生物（最多1只）
    local ct=0
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_SKULL,0,TYPES_TOKEN,1000,1000,1,RACE_ZOMBIE,ATTRIBUTE_DARK) then
        local token=Duel.CreateToken(tp,TOKEN_SKULL)
        if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
            ct=ct+1
            -- ② 赋予直接攻击能力
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DIRECT_ATTACK)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            token:RegisterEffect(e1)
        end
    end

    -- 生成僵尸衍生物（最多1只）
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ZOMBIE,0,TYPES_TOKEN,1000,1000,3,RACE_ZOMBIE,ATTRIBUTE_DARK) then
        local token=Duel.CreateToken(tp,TOKEN_ZOMBIE)
        if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
            ct=ct+1
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DIRECT_ATTACK)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            token:RegisterEffect(e1)
        end
    end

    if ct>0 then Duel.SpecialSummonComplete() end
end

-- ③ Cost：除外墓地里的这张卡
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToRemove() end
    Duel.Remove(c,POS_FACEUP,REASON_COST)
end

-- ③ 过滤函数（发动条件与处理共用，避免空发）
function s.thfilter(c,tp)
    return c:IsSetCard(NM) and c:IsAbleToHand()
        and not Duel.IsExistingMatchingCard(s.namecheck,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
function s.namecheck(c,code)
    return c:IsCode(code)
end

-- ③ Target：检查是否存在合法目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- ③ Operation：检索
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end