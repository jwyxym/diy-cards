--ゴーストリック
local s,id,o=GetID()
function s.initial_effect(c)
    -- 超量召唤
    c:EnableReviveLimit()
    aux.AddXyzProcedure(c,nil,1,3,s.ovfilter,aux.Stringid(id,0),1,s.xyzop)

    -- ①效果：从额外卡组特召时从手卡/卡组特召鬼计怪兽（里侧守备），这个回合只能特召暗属性
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.spcon1)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    -- ②效果：取除1素材，墓地的鬼计卡回到卡组顶，可以把等量里侧怪兽变表侧
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_POSITION)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1)
    e2:SetCost(s.cost2)
    e2:SetTarget(s.tgtg2)
    e2:SetOperation(s.tgop2)
    c:RegisterEffect(e2)

    -- ③效果：被送去墓地时，除外的鬼计卡加入手卡
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,3))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCondition(s.thcon)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

-- 超量召唤素材过滤：鬼计怪兽（从额外卡组特殊召唤的）
function s.ovfilter(c)
    return c:IsSetCard(0x8d) and c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA) and not c:IsCode(id) and not c:IsType(TYPE_XYZ)
end

-- 叠放操作
function s.xyzop(e,tp,chk)
    if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end

-- ①效果：需要是从额外卡组特殊召唤
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end

function s.spfilter1(c,e,tp)
    return c:IsSetCard(0x8d) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
        Duel.ConfirmCards(1-tp,g)
        g:GetFirst():ReverseInDeck()
        local c=e:GetHandler()
        -- 这个回合只能特殊召唤暗属性怪兽
        local e1=Effect.CreateEffect(c)
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
    return not c:IsAttribute(ATTRIBUTE_DARK)
end

-- ②效果：取除素材，墓地的鬼计卡回卡组顶，可以把等量里侧怪兽变表侧
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.tgfilter2(c)
    return c:IsSetCard(0x8d)
end

function s.tgtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tgfilter2(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.tgfilter2,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.tgfilter2,tp,LOCATION_GRAVE,0,1,99,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end

function s.tgop2(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(aux.NecroValleyFilter(Card.IsRelateToEffect),nil,e)
    if #tg>0 then
        -- 用喜欢的顺序回到卡组最上面
        local ct=aux.PlaceCardsOnDeckTop(tp,tg)
        if ct>0 and tg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then
            local dg=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,0,nil)
            if dg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POS)
                local sg=dg:Select(tp,1,math.min(ct,#dg),nil)
                Duel.ChangePosition(sg,POS_FACEUP_DEFENSE)
            end
        end
    end
end

-- ③效果：被送去墓地时，除外的鬼计卡加入手卡
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsLocation(LOCATION_GRAVE)
end

function s.thfilter(c)
    return c:IsSetCard(0x8d) and c:IsAbleToHand() and c:IsFaceup()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end
end