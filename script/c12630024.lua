--姬装战线·SWW
--字段：姬装战线（0xFA1）

local s,id,o=GetID()
local SET_JI_ZHUANG=0xFA1

function s.initial_effect(c)
    --同调召唤条件：地属性调整+调整以外的地属性怪兽1只以上
    -- 优化：使用 aux.FilterBoolFunction 包装属性检查
    aux.AddSynchroProcedure(c,
        aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH),  -- 调整：地属性
        aux.NonTuner(Card.IsAttribute,ATTRIBUTE_EARTH),             -- 非调整：地属性
        1, 99)  -- 最少1只，最多99只非调整
    c:EnableReviveLimit()
    
    --①：同调召唤成功时，回收墓地·除外的姬装战线卡回卡组底，然后抽1张
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.drtg)
    e1:SetOperation(s.drop)
    c:RegisterEffect(e1)
    
    --②：姬装战线怪兽的战斗伤害变成2倍
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.damtg)
    e2:SetValue(s.damval)
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
function s.tdfilter(c)
    return c:IsSetCard(SET_JI_ZHUANG) and c:IsAbleToDeck()
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return (chkc:IsLocation(LOCATION_GRAVE) or chkc:IsLocation(LOCATION_REMOVED)) and chkc:IsControler(tp) and s.tdfilter(chkc) end
    if chk==0 then
        return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
            and Duel.IsPlayerCanDraw(tp,1)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

--①效果处理
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    
    --回到卡组最下面
    if Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)==0 then return end
    
    --那之后，抽1张
    Duel.BreakEffect()
    Duel.Draw(tp,1,REASON_EFFECT)
    
    --自肃：直到回合结束时自己不是机械族·地属性怪兽不能特殊召唤
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

--②效果：战斗伤害目标
function s.damtg(e,c)
    return c:IsSetCard(SET_JI_ZHUANG) and c:IsType(TYPE_MONSTER)
end

--②效果：战斗伤害值
function s.damval(e,c)
    return DOUBLE_DAMAGE
end

--③效果目标
function s.tdfilter2(c,exclude)
    return c:IsSetCard(SET_JI_ZHUANG) and c~=exclude and c:IsAbleToDeck()
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return (chkc:IsLocation(LOCATION_GRAVE) or chkc:IsLocation(LOCATION_REMOVED)) and chkc:IsControler(tp) and s.tdfilter2(chkc,c) end
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
            and Duel.IsExistingTarget(s.tdfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,c)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.tdfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,c)
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
    
    --特殊召唤自身
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        --对象回卡组
        if tc and tc:IsRelateToEffect(e) then
            Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        end
    end
end

--特殊召唤限制
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return not (c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH))
end
