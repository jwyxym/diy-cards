-- 跃音萌行 玛莉嘉
-- ID: 26051972
-- 字段：跃音萌行 0x906 / 凛 0x907 / 布若 0x908 / 玛莉嘉 0x909
local s,id=GetID()
function s.initial_effect(c)
    -- ① 召唤·特殊召唤成功时，从手卡·卡组特召「布若」或「凛」
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    -- ② 链接怪兽被送去自己墓地的结束阶段，这张卡从墓地加入手卡
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id+1000)
    e3:SetCondition(s.thcon)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)

    -- 全局标记：记录链接怪兽被送去墓地
    if not s.global_check then
        s.global_check=true
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_TO_GRAVE)
        ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ge1:SetOperation(s.regop)
        Duel.RegisterEffect(ge1,0)
    end
end

-- 效果①过滤：「布若」(0x908) 或「凛」(0x907)
function s.spfilter(c,e,tp)
    return (c:IsSetCard(0x908) or c:IsSetCard(0x907))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
            -- 自肃：直到回合结束，自己不是「跃音萌行」怪兽不能从额外卡组特殊召唤
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e1:SetTargetRange(1,0)
            e1:SetTarget(s.splimit)
            e1:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e1,tp)
        end
    end
end
function s.splimit(e,c)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x906)
end

-- 效果② 链接怪兽送墓标记
function s.gfilter(c)
    return c:IsType(TYPE_LINK)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.gfilter,nil)
    if #g>0 then
        for tc in aux.Next(g) do
            Duel.RegisterFlagEffect(tc:GetControler(), id, RESET_PHASE+PHASE_END, 0, 1)
        end
    end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)>0
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
    end
end