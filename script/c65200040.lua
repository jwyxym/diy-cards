-- 《<梦魇>恶魔鼓手·拉兹》
-- 卡号：65200040  暗/不死族/2星 500/1000
local s,id=GetID()
local NM=0x32a
local TOKEN_SKULL=65200900

function s.initial_effect(c)
    -- ① 手卡特召 + 可选破坏
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- ② 从场上送去墓地的场合，生成衍生物 + 可选堆墓
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_DECKDES)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)               -- 事件：送去墓地
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.gycon)                 -- 条件：从场上送墓
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)
end

-- ①
function s.spcon(e,tp)
    return Duel.IsExistingMatchingCard(function(c) return c:IsSetCard(NM) end,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        local dg=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:IsDefenseBelow(1500) end,tp,0,LOCATION_MZONE,nil)
        if #dg>0 and Duel.SelectYesNo(tp,"破坏对方场上1只守备力1500以下的怪兽吗？") then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local sg=dg:Select(tp,1,1,nil)
            if #sg>0 then Duel.HintSelection(sg) Duel.Destroy(sg,REASON_EFFECT) end
        end
    end
end

-- ② 条件：从场上送去墓地
function s.gycon(e,tp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ② 目标
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_SKULL,0,TYPES_TOKEN,1000,1000,1,RACE_ZOMBIE,ATTRIBUTE_DARK) end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
-- ② 操作
function s.gyop(e,tp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_SKULL,0,TYPES_TOKEN,1000,1000,1,RACE_ZOMBIE,ATTRIBUTE_DARK) then return end
    local token=Duel.CreateToken(tp,TOKEN_SKULL)
    if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
        Duel.SpecialSummonComplete()
        -- 可选堆墓
        local g=Duel.GetMatchingGroup(s.dumpfilter,tp,LOCATION_DECK,0,nil,tp)
        if #g>0 and Duel.SelectYesNo(tp,"从卡组将1张同名卡不在墓地存在的「<梦魇>」卡送去墓地吗？") then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local sg=g:Select(tp,1,1,nil)
            if #sg>0 then Duel.SendtoGrave(sg,REASON_EFFECT) end
        end
    end
end
function s.dumpfilter(c,tp)
    return c:IsSetCard(NM) and c:IsAbleToGrave()
        and not Duel.IsExistingMatchingCard(function(tc,code) return tc:IsCode(code) end,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end