-- 汇集的世坏之力
-- ID: 12950004
-- 字段：恐吓爪牙族 0x17a / 珠泪哀歌族 0x181 / 俱舍怒威族 0x189 / 末那愚子族 0x190
local s,id=GetID()
function s.initial_effect(c)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetValue(0x17a)
    c:RegisterEffect(e0)
    local e0a=e0:Clone()
    e0a:SetValue(0x181)
    c:RegisterEffect(e0a)
    local e0b=e0:Clone()
    e0b:SetValue(0x189)
    c:RegisterEffect(e0b)
    local e0c=e0:Clone()
    e0c:SetValue(0x190)
    c:RegisterEffect(e0c)

    -- 永续魔法发动
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- ① 主阶展示额外1只哈特
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.chtg)
    e2:SetOperation(s.chop)
    c:RegisterEffect(e2)

    -- ② 被除外时
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_REMOVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_REMOVED)
    e3:SetCountLimit(1,id+1000)
    e3:SetCondition(s.rmcon)
    e3:SetTarget(s.retg)
    e3:SetOperation(s.reop)
    c:RegisterEffect(e3)

    -- ② 被效果送墓时
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1,id+1000)
    e4:SetCondition(s.gycon)
    e4:SetTarget(s.retg)
    e4:SetOperation(s.reop)
    c:RegisterEffect(e4)
end

-- 哈特过滤
function s.hfilter(c)
    return c:IsSetCard(0x1a0) and c:IsType(TYPE_MONSTER)
end

-- ① 效果
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.hfilter,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.hfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    Duel.ConfirmCards(1-tp,g)
    e:SetLabelObject(g:GetFirst())
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if not tc then return end
    if tc:IsType(TYPE_LINK) then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.hfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE) end
    elseif tc:IsType(TYPE_FUSION) then
        if not Duel.IsExistingMatchingCard(s.hfilter,tp,LOCATION_HAND,0,1,nil) then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,s.hfilter,tp,LOCATION_HAND,0,1,1,nil)
        Duel.SendtoGrave(g,REASON_EFFECT)
        if Duel.IsExistingMatchingCard(s.hfilter,tp,LOCATION_DECK,0,1,nil) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local sg=Duel.SelectMatchingCard(tp,s.hfilter,tp,LOCATION_DECK,0,1,1,nil)
            Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
        end
    elseif tc:IsType(TYPE_XYZ) then
        local g=Group.CreateGroup()
        if Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local hg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
            g:Merge(hg)
        end
        if Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,nil) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local gg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,1,nil)
            g:Merge(gg)
        end
        if #g>0 then Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT) end
        
        if Duel.IsExistingMatchingCard(Card.IsAbleToRemove,1-tp,LOCATION_ONFIELD,0,1,nil) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
            local rg=Duel.SelectMatchingCard(1-tp,Card.IsAbleToRemove,1-tp,LOCATION_ONFIELD,0,1,1,nil)
            if #rg>0 then Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT) end
        end
    elseif tc:IsType(TYPE_SYNCHRO) then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        local f=function(c) return c:IsAttack(1500) and c:IsDefense(2100) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,f,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            g:GetFirst():RegisterEffect(e1)
        end
    end
end

-- ② 条件与处理
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    -- 必须是表侧除外才能发动
    return e:GetHandler():IsFaceup()
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_EFFECT)
end
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

-- 【修复】直接使用 MoveToField 表侧放回，不要回手和 SSet 的动画
function s.reop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsLocation(LOCATION_GRAVE) then
        c:CancelToGrave()
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    elseif c:IsLocation(LOCATION_REMOVED) then
        -- 如果卡是表侧除外，直接放回魔陷区
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end