-- 《<梦魇>挽歌·人生苦短》
-- 卡号：65200180  暗/不死族/10星/同调 3250/2750
local s,id=GetID()
local NM=0x32a

function s.initial_effect(c)
    c:EnableReviveLimit()
    -- 同调召唤手续（照抄真红眼不死龙皇）
    aux.AddSynchroProcedure(c,
        aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),
        aux.NonTuner(nil),
        1)

    -- ① 同调召唤成功时，卡组不死族堆墓或特召
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.syncon)
    e1:SetTarget(s.syntg)
    e1:SetOperation(s.synop)
    c:RegisterEffect(e1)

    -- ② 有衍生物时，不死族效果怪兽双抗
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetCondition(s.protcon)
    e2:SetTarget(s.prottg)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetCondition(s.protcon)
    e3:SetTarget(s.prottg)
    e3:SetValue(aux.indoval)
    c:RegisterEffect(e3)

    -- ③ 衍生物被解放时，从墓地·除外检索<梦魇>卡
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_CUSTOM+id)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id+1)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)
    -- 监控解放事件
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_RELEASE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCondition(s.regcon)
    e5:SetOperation(s.regop)
    c:RegisterEffect(e5)
end

-- ① 条件：同调召唤
function s.syncon(e,tp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- ① 目标
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_DECK,0,1,nil,RACE_ZOMBIE) end
end
-- ① 操作：堆墓或特召
function s.synop(e,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
    local g=Duel.SelectMatchingCard(tp,Card.IsRace,tp,LOCATION_DECK,0,1,1,nil,RACE_ZOMBIE)
    if #g==0 then return end
    local tc=g:GetFirst()
    local b1=tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
    local b2=tc:IsAbleToGrave()
    if b1 and b2 then
        if Duel.SelectOption(tp,"特殊召唤","送去墓地")==0 then
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        else
            Duel.SendtoGrave(tc,REASON_EFFECT)
        end
    elseif b1 then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    elseif b2 then
        Duel.SendtoGrave(tc,REASON_EFFECT)
    end
end

-- ② 双抗条件：场上有衍生物
function s.protcon(e)
    return Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,TYPE_TOKEN)
end
-- ② 双抗目标：自己的不死族效果怪兽
function s.prottg(e,c)
    return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_EFFECT)
end

-- ③ 监控条件：衍生物被解放
function s.regcon(e,tp,eg)
    return eg:IsExists(Card.IsType,1,nil,TYPE_TOKEN)
end
-- ③ 监控操作：触发自定义事件
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    if re and re:GetHandler():IsRace(RACE_ZOMBIE) then
        Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,re,0,tp,tp,0)
    end
end
-- ③ 检索目标（仅墓地·除外）
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ③ 检索操作（仅墓地·除外）
function s.thop(e,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
function s.thfilter(c)
    return c:IsSetCard(NM) and c:IsAbleToHand()
end