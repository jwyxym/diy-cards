--姬装战线·TYPE
--字段：姬装战线（0xFA1）

local s,id,o=GetID()
local SET_JI_ZHUANG=0xFA1

function s.initial_effect(c)
    --同调召唤条件：地属性调整+调整以外的地属性怪兽1只以上
    aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_EARTH),1,99)
    c:EnableReviveLimit()
    
    --①：同调召唤成功时，回收墓地·除外的4星以下姬装战线怪兽（加入手卡或特招）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    
    --②：场上姬装战线怪兽攻击力上升550
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.atktg)
    e2:SetValue(550)
    c:RegisterEffect(e2)
    
    --③：墓地发动，回收墓地·除外的其他姬装战线卡，这张卡特招
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,id+o)
    e3:SetTarget(s.sptg2)
    e3:SetOperation(s.spop2)
    c:RegisterEffect(e3)
end

--①效果条件：同调召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

--①效果目标
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_JI_ZHUANG) and c:IsLevelBelow(4) and c:IsType(TYPE_MONSTER)
        and (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED))
        and (c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return (chkc:IsLocation(LOCATION_GRAVE) or chkc:IsLocation(LOCATION_REMOVED)) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
    if chk==0 then
        return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

--①效果处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    
    -- 玩家选择：加入手卡(0) 或 特殊召唤(1)
    local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    if opt==0 then
        -- 加入手卡
        if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
            Duel.ConfirmCards(1-tp,tc)
        end
    else
        -- 特殊召唤
        if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        end
    end
    
    -- 自肃：直到回合结束时自己不是机械族·地属性怪兽不能特殊召唤
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return not (c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH))
end

--②效果：攻击力上升目标
function s.atktg(e,c)
    return c:IsSetCard(SET_JI_ZHUANG) and c:IsType(TYPE_MONSTER)
end

--③效果目标
function s.tdfilter(c,exclude)
    return c:IsSetCard(SET_JI_ZHUANG) and c~=exclude and c:IsAbleToDeck()
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return (chkc:IsLocation(LOCATION_GRAVE) or chkc:IsLocation(LOCATION_REMOVED)) and chkc:IsControler(tp) and s.tdfilter(chkc,c) end
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
            and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,c)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,c)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end

--③效果处理
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    
    if not c:IsRelateToEffect(e) then return end
    if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    
    -- 特殊召唤自身
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        -- 对象回卡组
        if tc and tc:IsRelateToEffect(e) then
            Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        end
    end
end
