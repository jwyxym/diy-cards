-- 《<梦魇>骸骨驯兽师》
-- 卡号：65200150  暗/不死族/7星 1500/2000
local s,id=GetID()
local NM=0x32a
local TOKEN_SKULL=65200900
local TOKEN_ZOMBIE=65200901

function s.initial_effect(c)
    -- ① 解放怪兽从手卡·墓地特召 + 生成衍生物
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

    -- ② 衍生物直接攻击（在生成衍生物时赋予，不需要单独注册）
    
    -- ③ 墓地除外检索
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

-- ① Target
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

-- ① Operation：特召自身 + 生成衍生物
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

    -- 生成僵尸衍生物（最多1只，如果还有空位）
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ZOMBIE,0,TYPES_TOKEN,1000,1000,3,RACE_ZOMBIE,ATTRIBUTE_DARK) then
        local token=Duel.CreateToken(tp,TOKEN_ZOMBIE)
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

    if ct>0 then Duel.SpecialSummonComplete() end
end

-- ③ Cost：除外墓地里的这张卡
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToRemove() end
    Duel.Remove(c,POS_FACEUP,REASON_COST)
end

-- ③ Target
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- ③ Operation
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
    if #g>0 then
        Duel.SendToHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- ③ 过滤：同名卡不在墓地的<梦魇>卡
function s.thfilter(c,tp)
    return c:IsSetCard(NM) and c:IsAbleToHand()
        and not Duel.IsExistingMatchingCard(s.namecheck,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
function s.namecheck(c,code)
    return c:IsCode(code)
end