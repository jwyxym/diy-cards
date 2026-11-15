-- 鬼神残炎 冥藏
-- ID: 12940005
-- 字段：艮神鬼 0x1e4
local s,id=GetID()
function s.initial_effect(c)
    -- ① 手卡作为「艮神鬼」同调怪兽的同调素材
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EXTRA_SYNCHRO_MATERIAL)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetValue(s.matval)
    c:RegisterEffect(e1)

    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_BE_PRE_MATERIAL)
    e0:SetProperty(EFFECT_FLAG_EVENT_PLAYER+EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetLabelObject(e1)
    e0:SetCondition(s.hsyncon)
    e0:SetOperation(s.hsynreg)
    c:RegisterEffect(e0)

    -- ② 展示手卡1张魔陷或本家卡：特召，检索本家卡
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,id+1000)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- ③ 作为同调素材送墓：墓地/除外最多3张本家卡或陷阱回卡组上方，这张卡里侧守备特召
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id+2000)
    e3:SetCondition(s.tdcon)
    e3:SetTarget(s.tdtg)
    e3:SetOperation(s.tdop)
    c:RegisterEffect(e3)
end

-- ①
function s.matval(e,c)
    return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x1e4)
end
function s.hsyncon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return r==REASON_SYNCHRO and s.matval(nil,c:GetReasonCard()) and c:IsPreviousLocation(LOCATION_HAND)
end
function s.hsynreg(e,tp,eg,ep,ev,re,r,rp)
    e:GetLabelObject():UseCountLimit(tp)
end

-- ②
function s.showfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) or c:IsSetCard(0x1e4)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.IsExistingMatchingCard(s.showfilter,tp,LOCATION_HAND,0,1,c) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.showfilter,tp,LOCATION_HAND,0,1,1,c)
    Duel.ConfirmCards(1-tp,g)
end
function s.spfilter(c)
    return c:IsSetCard(0x1e4) and c:IsAbleToHand()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
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
function s.splimit(e,c)
    if not c:IsLocation(LOCATION_EXTRA) then return false end
    return not c:IsType(TYPE_SYNCHRO)
end

-- ③
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end

-- 修正：本家卡 或 陷阱卡
function s.tdfilter(c)
    return (c:IsSetCard(0x1e4) or c:IsType(TYPE_TRAP)) and c:IsAbleToDeck()
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    -- 修正：排除自身，包含墓地+除外
    local function f(gc)
        return gc~=c and s.tdfilter(gc)
    end
    if chkc then
        return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and f(chkc)
    end
    if chk==0 then
        return Duel.IsExistingTarget(f,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,f,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,3,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    if g:GetCount()>0 then
        -- 逐张选择顺序：第一张选的放到最上面
        local remain=g:Clone()
        local ordered=Group.CreateGroup()
        while remain:GetCount()>0 do
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
            local tc=remain:Select(tp,1,1,nil):GetFirst()
            if not tc then break end
            ordered:AddCard(tc)
            remain:RemoveCard(tc)
        end
        if ordered:GetCount()>0 then
            Duel.SendtoDeck(ordered,nil,SEQ_DECKTOP,REASON_EFFECT)
        end
    end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
        Duel.ConfirmCards(1-tp,c)
    end
end