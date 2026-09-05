-- 《<梦魇>挽歌·人生苦短》
-- 卡号：65200180
-- 属性：暗 种族：不死族 等级：10 攻击：3250 守备：2750 同调
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

    -- ③ 自己场上的衍生物被解放的场合才能发动。
    --    从墓地·除外状态选1张<梦魇>卡加入手卡。
    --    改为：监控解放事件，直接触发检索。
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_RELEASE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id+100)
    e4:SetCondition(s.relcon)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)
end

function s.syncon(e,tp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_DECK,0,1,nil,RACE_ZOMBIE) end
end
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

function s.protcon(e)
    return Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,TYPE_TOKEN)
end
function s.prottg(e,c)
    return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_EFFECT)
end

-- ③ 条件：解放的卡中包含自己场上的衍生物
function s.relcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.relfilter,1,nil,tp)
end
function s.relfilter(c,tp)
    return c:IsPreviousControler(tp) and c:IsType(TYPE_TOKEN)
end

-- ③ 过滤：墓地·除外状态的<梦魇>卡
function s.thfilter(c)
    return c:IsSetCard(NM) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end