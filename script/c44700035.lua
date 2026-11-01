local s,id=GetID()
local SET_SEIKI = 0x474

function s.initial_effect(c)
    -- ① 墓地/除外拿圣辉（含里侧特召）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SSET+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- ② 光暗特召，加星加攻（持续两个回合）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(2,id+1)
    e2:SetCondition(s.lvcon)
    e2:SetTarget(s.lvtg)
    e2:SetOperation(s.lvop)
    c:RegisterEffect(e2)

    -- ③ 送墓表侧放置
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(2,id+1)
    e3:SetCondition(s.gycon)
    e3:SetOperation(s.gyop)
    c:RegisterEffect(e3)
end

function s.thfilter(c,e,tp)
    return c:IsSetCard(SET_SEIKI) and (
        c:IsAbleToHand() or 
        c:IsSSetable() or 
        (c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE))
    )
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
    if #g==0 then return end
    local tc=g:GetFirst()
    
    local b1 = tc:IsAbleToHand()
    local b2 = false
    local is_monster = tc:IsType(TYPE_MONSTER)
    
    if is_monster then
        b2 = Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
    else
        b2 = tc:IsSSetable()
    end
    
    if not b1 and not b2 then return end
    
    local op = 0
    if b1 and b2 then
        if is_monster then
            -- 怪兽：弹窗选加入手卡 还是 里侧特召
            op = Duel.SelectOption(tp, aux.Stringid(id,3), aux.Stringid(id,5))
        else
            -- 魔陷：弹窗选加入手卡 还是 盖放
            op = Duel.SelectOption(tp, aux.Stringid(id,3), aux.Stringid(id,4))
        end
    elseif b2 then
        op = 1
    end
    
    if op == 0 then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    else
        if is_monster then
            -- ★ 怪兽直接里侧守备特召
            Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEDOWN_DEFENSE)
        else
            -- ★ 魔陷盖放
            Duel.SSet(tp, tc)
        end
    end
end

function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c) 
        return c:IsFaceup() and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK)) 
    end, 1, nil)
end

function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
end

function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        local lv = 0
        if tc:IsType(TYPE_XYZ) then
            lv = tc:GetRank()
        elseif not tc:IsType(TYPE_LINK) then
            lv = tc:GetLevel()
        end

        if lv > 0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(tc:IsType(TYPE_XYZ) and EFFECT_UPDATE_RANK or EFFECT_UPDATE_LEVEL)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(3)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 2)
            tc:RegisterEffect(e1)
            
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_UPDATE_ATTACK)
            e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e2:SetValue(lv * 300)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 2)
            tc:RegisterEffect(e2)
        end
    end
end

function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_EFFECT) and re and re:GetHandler():IsType(TYPE_MONSTER)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end